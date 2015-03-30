module Protocore
  module Extractors
    class AuthorityExtractor

      def initialize(_, key_store, cert_store)
        @key_store = key_store
        @cert_store = cert_store
      end

      def call(config)
        config.tap do |config|
          config["authorities"] = config.fetch("authorities", {}).inject({}) do |authorities, (name, options)|
            authorities.tap { |a| a[name] = build_authority(name, options) }
          end
        end
      end

    private

      def build_authority(name, options)
        algorithm = extract_algorithm(options["algorithm"])
        signature = extract_signature(options["signature"])

        details_factory = Protocore::DetailsFactory.new({ "common_name" => name }.merge options)

        key = @key_store.find_or_create("authorities", name, algorithm: algorithm, bits: options["bits"])
        cert = @cert_store.find_or_create("authorities", name) {
          unsigned_cert = CertFactory.new(key, details_factory.call).call(serial: 1)
          Protocore::Authority.sign(unsigned_cert, key, signature: signature)
        }

        return Protocore::Authority.new(key, cert, details_factory, signature: signature)
      end

      def extract_algorithm(algorithm)
        case algorithm
        when /rsa/i then OpenSSL::PKey::RSA
        when /dsa/i then OpenSSL::PKey::DSA
        else raise NotImplementedError, "creating keys with the #{ algorithm } algorithm is not supported"
        end
      end

      def extract_signature(signature)
        case signature
        when /sha512/i then OpenSSL::Digest::SHA512
        when /sha256/i then OpenSSL::Digest::SHA256
        when /sha1/i then OpenSSL::Digest::SHA1
        else raise NotImplementedError, "signing certificates using #{ signature } is not supported"
        end
      end

    end
  end
end
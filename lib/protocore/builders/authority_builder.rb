module Protocore
  module Builders
    module AuthorityBuilder

      def build_authority(name, options)
        algorithm = build_algorithm(options["algorithm"])
        signature = build_signature(options["signature"])

        details_factory = Protocore::DetailsFactory.new({ "common_name" => name }.merge options)

        key = @key_store.find_or_create("authorities", name, algorithm: algorithm, bits: options["bits"])
        cert = @cert_store.find_or_create("authorities", name) {
          unsigned_cert = CertFactory.new(key, details_factory.call).call(serial: 1)
          Protocore::Authority.sign(unsigned_cert, key, signature: signature)
        }

        Protocore::Authority.new(key, cert, details_factory, signature: signature)
      end

    end
  end
end
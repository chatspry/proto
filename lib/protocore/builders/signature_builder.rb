module Protocore
  module Builders
    module SignatureBuilder

      def build_signature(signature)
        case signature
        when /sha512/i then OpenSSL::Digest::SHA512
        when /sha384/i then OpenSSL::Digest::SHA384
        when /sha256/i then OpenSSL::Digest::SHA256
        when /sha224/i then OpenSSL::Digest::SHA224
        when /sha1/i then OpenSSL::Digest::SHA1
        else raise NotImplementedError, "signing certificates using #{ signature } is not supported"
        end
      end

    end
  end
end
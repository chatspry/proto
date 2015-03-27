require "openssl"

module Protocore
  class Authority

    attr_reader :name, :details

    def initialize(name, details, cert_store:, key_store:, signature: OpenSSL::Digest::SHA256)
      @name = name
      @details_factory = Protocore::DetailsFactory.new({ "common_name" => name }.merge details)
      @details = @details_factory.call
      @signature = signature
      @key = key_store.find_or_create("authorities", @name)
      @cert = cert_store.find_or_create("authorities", @name) {
        CertFactory.new(@key, @details).call(serial: 1).tap do |cert|
          ef = OpenSSL::X509::ExtensionFactory.new
          ef.subject_certificate = cert
          ef.issuer_certificate = cert
          cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
          cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
          cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
          cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
          cert.sign(@key, @signature.new)
        end
      }
    end

    def issue(key, details)
      puts @details_factory.call(details)
      sign CertFactory.new(key, @details_factory.call(details), issuer: @details).call(serial: 2)
    end

    def sign(cert)
      cert.tap do |cert|
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = @cert
        cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
        cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
        cert.sign(@key, @signature.new)
      end
    end

  end
end
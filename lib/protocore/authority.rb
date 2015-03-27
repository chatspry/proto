require "openssl"

module Protocore
  class Authority

    attr_reader :name, :details, :signature

    def initialize(key, cert, details_factory, signature: OpenSSL::Digest::SHA256)
      @key = key
      @cert = cert
      @details_factory = details_factory
      @details = @details_factory.call
      @signature = signature
    end

    def issue(key, details={}, serial: 2)
      sign CertFactory.new(key, @details_factory.call(details), issuer: @details).call(serial: serial)
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

    def self.sign(cert, key, signature: OpenSSL::Digest::SHA256)
      cert.tap do |cert|
        ef = OpenSSL::X509::ExtensionFactory.new
        ef.subject_certificate = cert
        ef.issuer_certificate = cert
        cert.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
        cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
        cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
        cert.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
        cert.sign(key, signature.new)
      end
    end

  end
end
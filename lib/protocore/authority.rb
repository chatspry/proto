require "openssl"

module Protocore
  class Authority

    attr_reader :name, :details

    def initialize(name, details, cert_store:, key_store:, signature: OpenSSL::Digest::SHA256)
      @name = name
      @details = details
      @signature = signature
      @key = key_store.find_or_create
      @cert = cert_store.find_or_create {
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
      sign CertFactory.new(key, details, issuer: @details).call(serial: 2)
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

  private

    def self_sign

    end

  end
end
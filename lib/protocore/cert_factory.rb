module Protocore
  class CertFactory

    def initialize(key, details, issuer: nil)
      @key = key
      @details = details
      @issuer = issuer
    end

    def call(days: 730, version: 2)
      OpenSSL::X509::Certificate.new.tap do |cert|
        cert.version = 2
        cert.subject = @details
        cert.issuer = @issuer || @details
        cert.public_key = @key.public_key
        cert.not_before = Time.now
        cert.not_after = cert.not_before + days * 24 * 60 * 60
      end
    end

  end
end
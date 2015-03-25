require "openssl"

module Protocore
  class NameFactory

    OPTS = {
      "country" => ["C", OpenSSL::ASN1::PRINTABLESTRING],
      "state" => ["ST", OpenSSL::ASN1::PRINTABLESTRING],
      "city" => ["L", OpenSSL::ASN1::PRINTABLESTRING],
      "organization" => ["O", OpenSSL::ASN1::UTF8STRING],
      "department" => ["OU", OpenSSL::ASN1::UTF8STRING],
      "common_name" => ["CN", OpenSSL::ASN1::UTF8STRING],
      "email" => ["emailAddress", OpenSSL::ASN1::UTF8STRING],
    }

    attr_reader :options

    def initialize(options={})
      @options = options
    end

    def call
      @subject ||= OpenSSL::X509::Name.new(self.parse)
    end

    def parse
      OPTS.map { |key, a| [a.first, options[key], a.last] if options[key] }.compact
    end

  end
end
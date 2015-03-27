require "openssl"

module Protocore
  class NameFactory

    MAPPING = {
      "country" => ["C", OpenSSL::ASN1::PRINTABLESTRING],
      "state" => ["ST", OpenSSL::ASN1::PRINTABLESTRING],
      "city" => ["L", OpenSSL::ASN1::PRINTABLESTRING],
      "organization" => ["O", OpenSSL::ASN1::UTF8STRING],
      "department" => ["OU", OpenSSL::ASN1::UTF8STRING],
      "common_name" => ["CN", OpenSSL::ASN1::UTF8STRING],
      "email" => ["emailAddress", OpenSSL::ASN1::UTF8STRING],
    }

    attr_reader :details

    def initialize(details={})
      @details = details
    end

    def call(extra_details={})
      all_details = details.merge(extra_details)
      mapped_details = MAPPING.map { |key, spec| [spec.first, all_details[key], spec.last] if all_details[key] }.compact
      OpenSSL::X509::Name.new(mapped_details)
    end

  end
end
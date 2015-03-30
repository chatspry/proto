class Protocore::AuthorityBuilderTester
  include Protocore::Builders::AlgorithmBuilder
  include Protocore::Builders::SignatureBuilder
  include Protocore::Builders::AuthorityBuilder
  def initialize(key_store, cert_store)
    @key_store, @cert_store = key_store, cert_store
  end
end

RSpec.describe Protocore::Builders::AuthorityBuilder do

  let(:work_dir) { Protocore::WorkDir.new("/") }
  let(:key_store) { Protocore::KeyStore.new(work_dir) }
  let(:cert_store) { Protocore::CertStore.new(work_dir) }

  subject { Protocore::AuthorityBuilderTester.new(key_store, cert_store) }

  let(:authority_config) { {
    "algorithm" => "RSA",
    "signature" => "SHA512",
    "bits" => 1024,
    "days" => 3650,
    "country" => "AU",
    "city" => "Melbourne",
    "organization" => "Test Ltd.",
    "email" => "admin@example.com"
  } }

  describe "#build_authority" do

    it "should return a valid authority" do
      authority = subject.build_authority("CA_RSA", authority_config)
      expect(authority.signature).to eq OpenSSL::Digest::SHA512
      expect(authority.details.to_s).to eq "/C=AU/L=Melbourne/O=Test Ltd./CN=CA_RSA/emailAddress=admin@example.com"
    end

  end

end
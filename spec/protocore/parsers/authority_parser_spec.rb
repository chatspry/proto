RSpec.describe Protocore::Parsers::AuthoritiesParser do

  include FakeFS::SpecHelpers

  let(:work_dir) { Protocore::WorkDir.new("/").manifest! }
  let(:key_store) { Protocore::KeyStore.new(work_dir) }
  let(:cert_store) { Protocore::CertStore.new(work_dir) }

  subject(:parser) { described_class.new(key_store, cert_store) }

  let(:cluster_config) { {
    "authorities" => {
      "CA_RSA" => {
        "algorithm" => "RSA",
        "signature" => "SHA512",
        "bits" => 1024,
        "days" => 3650,
        "country" => "AU",
        "city" => "Melbourne",
        "organization" => "Test Ltd.",
        "email" => "admin@example.com"
      }
    }
  } }

  describe "#call" do

    it "should return a valid authority" do
      expect(parser.call(cluster_config)).to match a_hash_including("CA_RSA")
      authority = parser.call(cluster_config)["CA_RSA"]
      expect(authority).to be_kind_of Protocore::Authority
      expect(authority.signature).to eq OpenSSL::Digest::SHA512
      expect(authority.details.to_s).to eq "/C=AU/L=Melbourne/O=Test Ltd./CN=CA_RSA/emailAddress=admin@example.com"
      expect(File.exist?("/.protocore/certs/authorities/CA_RSA.crt")).to eq true
      expect(File.exist?("/.protocore/keys/authorities/CA_RSA.pem")).to eq true
    end

  end

end
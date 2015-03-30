RSpec.describe Protocore::Extractors::AuthorityExtractor do

  let(:work_dir) { Protocore::WorkDir.new("/") }
  let(:key_store) { Protocore::KeyStore.new(work_dir) }
  let(:cert_store) { Protocore::CertStore.new(work_dir) }

  subject(:extractor) { described_class.new(key_store, cert_store) }

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
      config = extractor.call(cluster_config)
      expect(config).to match a_hash_including(
        "authorities" => { "CA_RSA" => an_instance_of(Protocore::Authority) }
      )
      authority = config["authorities"]["CA_RSA"]
      expect(authority.signature).to eq OpenSSL::Digest::SHA512
      expect(authority.details.to_s).to eq "/C=AU/L=Melbourne/O=Test Ltd./CN=CA_RSA/emailAddress=admin@example.com"
    end

  end

end
RSpec.describe Protocore::Authority do

  include FakeFS::SpecHelpers

  let!(:_context) { Protocore::Context.new("/").manifest! }

  let(:details) { { "common_name" => "1.test.local" } }
  let(:issuer) { { "country" => "GB", "city" => "London", "common_name" => "test.local" } }

  let(:details_factory) { Protocore::DetailsFactory.new(issuer) }
  let(:key) { OpenSSL::PKey::RSA.new(512) }
  let(:cert) {
    cert = Protocore::CertFactory.new(key, details_factory.call).call(serial: 1)
    Protocore::Authority.sign(cert, key)
  }

  subject(:authority) { described_class.new(key, cert, details_factory) }

  describe "#issue" do
    it "generates a certificate for the name" do
      cert = authority.issue(key, details)
      expect(cert).to be_kind_of OpenSSL::X509::Certificate
      expect(cert.subject.to_s).to eq "/C=GB/L=London/CN=1.test.local"
      expect(cert.issuer.to_s).to eq "/C=GB/L=London/CN=test.local"
      expect(File.exist?("/.protocore/certs/authorities/test.local.crt")).to eq false
      expect(File.exist?("/.protocore/keys/authorities/test.local.pem")).to eq false
    end
  end

  describe "#sign" do
    it "signs a certificate for a name" do
      cert = Protocore::CertFactory.new(key, details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end
  end

end
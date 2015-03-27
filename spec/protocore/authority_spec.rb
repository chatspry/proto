RSpec.describe Protocore::Authority do

  include FakeFS::SpecHelpers

  let!(:_context) { Protocore::Context.new("/").manifest! }

  let(:key) { OpenSSL::PKey::RSA.new(512) }

  let(:details) { { "common_name" => "1.test.local" } }
  let(:issuer) { { "country" => "GB", "city" => "London" } }

  let(:key_store) { Protocore::KeyStore.new(_context) }
  let(:cert_store) { Protocore::CertStore.new(_context) }

  subject(:authority) { described_class.new("test.local", issuer, key_store: key_store, cert_store: cert_store) }

  describe "#issue" do
    it "generates a certificate for the name" do
      cert = authority.issue(key, details)
      expect(cert).to be_kind_of OpenSSL::X509::Certificate
      expect(cert.subject.to_s).to eq "/C=GB/L=London/CN=1.test.local"
      expect(cert.issuer.to_s).to eq "/C=GB/L=London/CN=test.local"
      expect(File.open("/.protocore/certs/authorities/test.local.crt")).to exist
      expect(File.open("/.protocore/keys/authorities/test.local.pem")).to exist
    end
  end

  describe "#sign" do
    it "signs a certificate for a name" do
      cert = Protocore::CertFactory.new(key, Protocore::DetailsFactory.new(issuer).call(details), issuer: Protocore::DetailsFactory.new(issuer).call).call
      expect { authority.sign(cert) }.to_not raise_error
    end
  end

end
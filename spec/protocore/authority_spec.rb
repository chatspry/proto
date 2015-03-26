RSpec.describe Protocore::Authority do

  include FakeFS::SpecHelpers

  let!(:_context) { Protocore::Context.new("/").manifest! }

  let(:key) { OpenSSL::PKey::RSA.new(512) }

  let(:issuer) { OpenSSL::X509::Name.parse("/C=GB/L=London/CN=test.local") }
  let(:details) { OpenSSL::X509::Name.parse("/C=GB/L=London/CN=1.test.local") }
  let(:key_store) { Protocore::KeyStore.new(_context) }
  let(:cert_store) { Protocore::CertStore.new(_context) }

  subject(:authority) { described_class.new("test.local", issuer, key_store: key_store, cert_store: cert_store) }

  describe "#issue" do
    it "generates a certificate for the name" do
      cert = authority.issue(key, details)
      expect(cert).to be_kind_of OpenSSL::X509::Certificate
      expect(cert.subject.to_s).to eq details.to_s
      expect(cert.issuer.to_s).to eq issuer.to_s
    end
  end

  describe "#sign" do
    it "signs a certificate for a name" do
      cert = Protocore::CertFactory.new(key, details, issuer: issuer).call
      expect { authority.sign(cert) }.to_not raise_error
    end
  end

end
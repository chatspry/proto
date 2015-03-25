RSpec.describe Protocore::CertFactory do

  let(:key) { OpenSSL::PKey::RSA.new(512) }

  describe "#issue" do

    it "generates a valid self-signed certificate" do
      details = OpenSSL::X509::Name.parse("/C=GB/L=London/CN=test.local")
      cert = described_class.new(key, details).call
      cert.sign(key, OpenSSL::Digest::SHA256.new)
      expect_valid_certificiate(cert, key, details, details)
    end

    it "generates a valid authority signed certificate" do
      issuer = OpenSSL::X509::Name.parse("/C=GB/L=London/CN=test.local")
      details = OpenSSL::X509::Name.parse("/C=GB/L=London/CN=1.test.local")
      cert = described_class.new(key, details, issuer: issuer).call
      cert.sign(OpenSSL::PKey::RSA.new(512), OpenSSL::Digest::SHA256.new)
      expect_valid_certificiate(cert, key, details, issuer)
    end

    def expect_valid_certificiate(cert, key, details, issuer)
      expect(cert).to be_kind_of OpenSSL::X509::Certificate
      expect { cert = OpenSSL::X509::Certificate.new(cert.to_pem) }.to_not raise_error
      expect(cert.subject.to_s).to eq details.to_s
      expect(cert.issuer.to_s).to eq issuer.to_s
      expect(cert.public_key.to_s).to eq key.public_key.to_s
    end

  end

end
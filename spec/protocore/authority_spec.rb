RSpec.describe Protocore::Authority do

  let(:details) { { "common_name" => "1.test.local" } }
  let(:issuer) { { "country" => "GB", "city" => "London", "common_name" => "test.local" } }

  let(:details_factory) { Protocore::DetailsFactory.new(issuer) }

  def build_authority(bits, **args)
    ca_key = OpenSSL::PKey::RSA.new(bits)
    ca_cert = Protocore::CertFactory.new(ca_key, details_factory.call).call(serial: 1)
    Protocore::Authority.sign(ca_cert, ca_key)
    described_class.new(ca_key, ca_cert, details_factory, **args)
  end

  describe "#issue" do
    it "generates a certificate for the name" do
      authority = build_authority(512)
      cert = authority.issue(OpenSSL::PKey::RSA.new(128), details)
      expect(cert).to be_kind_of OpenSSL::X509::Certificate
      expect(cert.subject.to_s).to eq "/C=GB/L=London/CN=1.test.local"
      expect(cert.issuer.to_s).to eq "/C=GB/L=London/CN=test.local"
    end
  end

  describe "#sign" do
    it "signs a certificate with SHA1" do
      authority = build_authority(512, signature: OpenSSL::Digest::SHA1)
      cert = Protocore::CertFactory.new(OpenSSL::PKey::RSA.new(128), details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end

    it "signs a certificate with SHA224" do
      authority = build_authority(512, signature: OpenSSL::Digest::SHA224)
      cert = Protocore::CertFactory.new(OpenSSL::PKey::RSA.new(128), details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end

    it "signs a certificate with SHA256" do
      authority = build_authority(512, signature: OpenSSL::Digest::SHA256)
      cert = Protocore::CertFactory.new(OpenSSL::PKey::RSA.new(128), details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end

    it "signs a certificate with SHA384" do
      authority = build_authority(1024, signature: OpenSSL::Digest::SHA384)
      cert = Protocore::CertFactory.new(OpenSSL::PKey::RSA.new(128), details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end

    it "signs a certificate with SHA512" do
      authority = build_authority(1024, signature: OpenSSL::Digest::SHA512)
      cert = Protocore::CertFactory.new(OpenSSL::PKey::RSA.new(128), details_factory.call(details), issuer: details_factory.call).call
      expect { authority.sign(cert) }.to_not raise_error
    end
  end

end
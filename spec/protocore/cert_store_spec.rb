RSpec.describe Protocore::CertStore do

  subject!(:store) { Protocore::CertStore.new(Protocore::WorkDir.new("/")) }

  let(:key) { OpenSSL::PKey::RSA.new(512) }
  let(:cert) {
    OpenSSL::X509::Certificate.new.tap do |c|
      c.public_key = key.public_key
      c.not_before = Time.now
      c.not_after = c.not_before + 1 * 365 * 24 * 60 * 60
      c.sign(key, OpenSSL::Digest::SHA256.new)
    end
  }

  describe "#path" do
    it { expect(subject.path.to_s).to end_with "/certs" }
  end

  describe "#find_or_create" do

    it "creates a new cert" do
      file_path = "/.protocore/certs/foo/test.local.crt"
      new_cert = subject.find_or_create("foo", "test.local") { cert }
      expect(new_cert).to be_kind_of OpenSSL::X509::Certificate
      expect(new_cert.to_pem).to eq cert.to_pem
      expect(new_cert.object_id).to eq cert.object_id
    end

  end

end
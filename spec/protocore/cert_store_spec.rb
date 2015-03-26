RSpec.describe Protocore::CertStore do

  include FakeFS::SpecHelpers

  subject!(:store) { Protocore::CertStore.new(Protocore::Context.new("/").manifest!) }

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
      expect(File.exists? file_path).to eq true
    end

    it "uses the existing cert when the file exists" do
      file_path = "/.protocore/certs/test.local.crt"
      File.open(file_path, "w") { |file| file.write cert.to_pem }
      existing_cert = subject.find_or_create("test.local") { cert }
      expect(existing_cert).to be_kind_of OpenSSL::X509::Certificate
      expect(existing_cert.to_pem).to eq cert.to_pem
      expect(existing_cert.object_id).to_not eq cert.object_id
    end

  end

end
RSpec.describe Protocore::CertStore do

  let(:key) { OpenSSL::PKey::RSA.new(512) }
  let(:cert) {
    OpenSSL::X509::Certificate.new.tap do |c|
      c.public_key = key.public_key
      c.not_before = Time.now
      c.not_after = c.not_before + 1 * 365 * 24 * 60 * 60
      c.sign(key, OpenSSL::Digest::SHA256.new)
    end
  }

  subject { Protocore::CertStore.new(work_dir.to_s, "test.local") }

  describe "#file_path" do
    it { expect(subject.file_path.to_s).to end_with "test.local.crt" }
  end

  describe "#find_or_create" do

    include FakeFS::SpecHelpers

    after(:each) { FileUtils.rm_rf(work_dir.join("test.local.crt").to_s) }

    it "creates a new cert" do
      file_path = work_dir.join("test.local.crt")
      new_cert = subject.find_or_create { cert }
      expect(new_cert).to be_kind_of OpenSSL::X509::Certificate
      expect(new_cert.object_id).to eq cert.object_id
      expect(File.exists? file_path).to eq true
    end

    it "uses the existing cert when the file exists" do
      file_path = work_dir.join("test.local.crt")
      File.open(file_path, "w") { |file| file.write cert.to_pem }

      existing_cert = subject.find_or_create { cert }
      expect(existing_cert).to be_kind_of OpenSSL::X509::Certificate
      expect(existing_cert.object_id).to_not eq cert.object_id
    end

  end

end
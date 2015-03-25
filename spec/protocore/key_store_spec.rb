RSpec.describe Protocore::KeyStore do

  subject { Protocore::KeyStore.new(work_dir.to_s, "test.local") }

  describe "#file_path" do
    it { expect(subject.file_path.to_s).to end_with "test.local.pem" }
  end

  describe "#find_or_create" do

    include FakeFS::SpecHelpers

    after(:each) { FileUtils.rm_rf(work_dir.join("test.local.pem").to_s) }

    it "creates a new key pair" do
      file_path = work_dir.join("test.local.pem")
      expect(File.exists? file_path).to eq false

      priv = subject.find_or_create(bits: 1024)
      expect(priv).to be_kind_of OpenSSL::PKey::RSA
      expect(priv).to be_private
      expect(priv.to_text.match(/(\d*) bit/)[1]).to eq "1024"
      expect(File.read file_path.to_s).to eq priv.to_pem
    end

    it "uses the found key pair when the files exist" do
      key = OpenSSL::PKey::RSA.new(1024)
      path = work_dir.join("test.local.pem")

      File.open(path, "w") { |file| file.write key.to_pem }

      priv = subject.find_or_create(bits: 1024)

      expect(priv).to be_kind_of OpenSSL::PKey::RSA
      expect(priv).to be_private
      expect(priv.to_text.match(/(\d*) bit/)[1]).to eq "1024"
      expect(priv.to_pem).to eq key.to_pem
      expect(priv.public_key.to_pem).to eq key.public_key.to_pem
    end

    it "handles RSA algorithm" do
      store = described_class.new(work_dir.to_s, "test.local")
      expect(store.find_or_create(bits: 128, algorithm: OpenSSL::PKey::RSA)).to be_kind_of OpenSSL::PKey::RSA
    end

    it "handles DSA algorithm" do
      store = described_class.new(work_dir.to_s, "test.local")
      expect(store.find_or_create(bits: 128, algorithm: OpenSSL::PKey::DSA)).to be_kind_of OpenSSL::PKey::DSA
    end

    it "raises an exception when there is no algorithm" do
      expect { described_class.new(work_dir.to_s, "test.local").find_or_create(algorithm: Object) }.to raise_error(ArgumentError)
    end

  end

end
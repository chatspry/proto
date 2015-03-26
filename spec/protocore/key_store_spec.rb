RSpec.describe Protocore::KeyStore do

  include FakeFS::SpecHelpers

  subject!(:store) { Protocore::KeyStore.new(Protocore::Context.new("/").manifest!) }

  describe "#path" do
    it { expect(store.path.to_s).to end_with "/keys" }
  end

  describe "#find_or_create" do

    it "creates a new key pair" do
      file_path = "/.protocore/keys/foo/test.local.pem"
      expect(File.exists? file_path).to eq false

      priv = store.find_or_create("foo", "test.local", bits: 1024)
      expect(priv).to be_kind_of OpenSSL::PKey::RSA
      expect(priv).to be_private
      expect(priv.to_text.match(/(\d*) bit/)[1]).to eq "1024"
      expect(File.read file_path.to_s).to eq priv.to_pem
    end

    it "uses the found key pair when the files exist" do
      key = OpenSSL::PKey::RSA.new(1024)
      file_path = "/.protocore/keys/test.local.pem"

      File.open(file_path, "w") { |file| file.write key.to_pem }

      priv = store.find_or_create("test.local", bits: 1024)

      expect(priv).to be_kind_of OpenSSL::PKey::RSA
      expect(priv).to be_private
      expect(priv.to_text.match(/(\d*) bit/)[1]).to eq "1024"
      expect(priv.to_pem).to eq key.to_pem
      expect(priv.public_key.to_pem).to eq key.public_key.to_pem
    end

    it "handles RSA algorithm" do
      expect(store.find_or_create("test.local", bits: 128, algorithm: OpenSSL::PKey::RSA)).to be_kind_of OpenSSL::PKey::RSA
    end

    it "handles DSA algorithm" do
      expect(store.find_or_create("test.local", bits: 128, algorithm: OpenSSL::PKey::DSA)).to be_kind_of OpenSSL::PKey::DSA
    end

    it "raises an exception when there is no algorithm" do
      expect { store.find_or_create("test.local", algorithm: Object) }.to raise_error(ArgumentError)
    end

  end

end
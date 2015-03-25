RSpec.describe Protocore::Context do

  include FakeFS::SpecHelpers

  let(:work_dir) { "/tmp/protocore" }
  subject(:context) { described_class.new(work_dir, user: "tester") }

  describe "#config_file_path" do
    it { expect(subject.config_file_path).to eq "/tmp/protocore/cluster_config.yml" }
  end

  describe "#root_path" do
    it { expect(subject.root_path).to eq Pathname.new "/tmp/protocore" }
  end

  describe "#state_path" do
    it { expect(subject.state_path).to eq Pathname.new "/tmp/protocore/.protocore" }
  end

  describe "#certs_path" do
    it { expect(subject.certs_path).to eq Pathname.new "/tmp/protocore/.protocore/certs" }
  end

  describe "#keys_path" do
    it { expect(subject.keys_path).to eq Pathname.new "/tmp/protocore/.protocore/keys" }
  end

  describe "#user" do
    it { expect(subject.user).to eq "tester" }
  end

  describe "#manifest!" do
    it "it creates the all protocore state subdirectories" do
      expect( Dir.exist? context.root_path ).to eq false
      context.manifest!
      expect( File.exist? context.config_file_path ).to eq true
      expect( Dir.exist? context.keys_path ).to eq true
      expect( Dir.exist? context.certs_path ).to eq true
    end
  end

end
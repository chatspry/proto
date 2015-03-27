RSpec.describe Protocore::WorkDir do

  include FakeFS::SpecHelpers

  subject { described_class.new("/", user: "tester") }

  describe "#config_file_path" do
    it { expect(subject.config_file_path).to eq "/cluster_config.yml" }
  end

  describe "#root_path" do
    it { expect(subject.root_path).to eq Pathname.new "/" }
  end

  describe "#state_path" do
    it { expect(subject.state_path).to eq Pathname.new "/.protocore" }
  end

  describe "#certs_path" do
    it { expect(subject.certs_path).to eq Pathname.new "/.protocore/certs" }
  end

  describe "#keys_path" do
    it { expect(subject.keys_path).to eq Pathname.new "/.protocore/keys" }
  end

  describe "#user" do
    it { expect(subject.user).to eq "tester" }
  end

  describe "#manifest!" do
    it "it creates the all protocore state subdirectories" do
      expect( Dir.exist? subject.state_path ).to eq false
      subject.manifest!
      expect( File.exist? subject.config_file_path ).to eq true
      expect( Dir.exist? subject.keys_path ).to eq true
      expect( Dir.exist? subject.certs_path ).to eq true
    end
  end

end
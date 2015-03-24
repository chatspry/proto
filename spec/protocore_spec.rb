require "pathname"

RSpec.describe Protocore do

  let(:fixtures_path) { Pathname.new(__FILE__).dirname.join("fixtures") }
  let(:cluster_data_file_path) { fixtures_path.join("cluster-config.yaml").to_s }

  describe ".load" do
    subject(:load) { described_class.load(cluster_data_file_path) }
    it { expect(load).to be_kind_of Array }
  end

  describe ".read" do
    subject(:read) { described_class.read(cluster_data_file_path) }
    it { expect(read).to be_kind_of String }
  end

  describe ".parse" do
    subject(:parse) { described_class.parse described_class.read cluster_data_file_path }
    it "contains an array of Hosts" do
      expect(parse).to match Array.new(3) { an_instance_of(Protocore::Host) }
    end
  end

  describe Protocore::Host do

    subject(:host) { Protocore.load(cluster_data_file_path).last }

    let(:cloud_config_file_path) { fixtures_path.join("db.1.cloud-config.yaml").to_s }

    describe "#to_yaml" do

      it "contains three hosts with the correct data" do
        expect(subject.to_yaml).to eq File.read(cloud_config_file_path)
      end

    end

  end

end
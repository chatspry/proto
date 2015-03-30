RSpec.describe Protocore::Plan do

  let(:work_dir) { Protocore::WorkDir.new(Pathname(__FILE__).join("../../fixtures/example")) }

  subject(:plan) { described_class.new(work_dir) }

  describe "#config" do
    it "loads the config and pass it through extractors" do
      config = plan.config
      expect(config).to be_kind_of Hash
      expect(config["authorities"]).to match a_hash_including({
        "CA_RSA" => an_instance_of(Hash),
        "CA_DSA" => an_instance_of(Hash),
      })
      expect(config["users"]).to match a_hash_including({
        "zeeraw" => an_instance_of(Hash),
        "tester" => an_instance_of(Hash),
      })
    end
  end

end
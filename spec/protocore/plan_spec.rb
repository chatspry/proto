RSpec.describe Protocore::Plan do

  let(:work_dir) { Protocore::WorkDir.new(Pathname(__FILE__).join("../../fixtures/example")) }

  subject(:plan) { described_class.new(work_dir) }

  describe "#state" do
    it "loads the config and pass it through extractors" do
      Timecop.freeze

      state = plan.state

      expect(state["timestamp"]).to eq Time.now.to_i * 1000
      expect(state["state"].keys).to include "authorities", "users", "templates", "machines"

      expect(state["state"]["authorities"]).to match a_hash_including({
        "CA_RSA" => an_instance_of(Hash),
        "CA_DSA" => an_instance_of(Hash),
      })

      expect(state["state"]["users"]).to match a_hash_including({
        "zeeraw" => an_instance_of(Hash),
        "tester" => an_instance_of(Hash),
      })

      expect(state["state"]["templates"]).to match a_hash_including({
        "default" => an_instance_of(Hash),
      })

      expect(state["state"]["machines"]).to match a_hash_including({
        "app.1" => an_instance_of(Hash),
        "app.2" => an_instance_of(Hash),
      })

      Timecop.return
    end
  end

end
RSpec.describe Protocore::Planners::AuthorityPlanner do

  let(:work_dir) { Protocore::WorkDir.new("/") }

  subject(:planner) { described_class.new(work_dir) }

  let(:cluster_state) { { "dumb" => "shit" } }
  let(:cluster_config) { {
    "authorities" => {
      "CA_RSA" => {
        "algorithm" => "RSA",
        "signature" => "SHA512",
        "bits" => "1024",
        "days" => "3650",
        "country" => "AU",
        "city" => "Melbourne",
        "organization" => "Test Ltd.",
        "email" => "admin@example.com"
      }
    }
  } }

  describe "#call" do
    it "plans the authorities information" do
      state = planner.call(cluster_config, cluster_state)
      expect(state).to match a_hash_including("dumb", "authorities" => { "CA_RSA" => an_instance_of(Hash) })
      expect(state["authorities"]["CA_RSA"]).to match a_hash_including(
        "algorithm" => "RSA",
        "signature" => "SHA512",
        "bits" => 1024,
        "days" => 3650,
        "country" => "AU",
        "city" => "Melbourne",
        "organization" => "Test Ltd.",
        "email" => "admin@example.com"
      )
    end
  end

end
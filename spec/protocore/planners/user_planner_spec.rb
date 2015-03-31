RSpec.describe Protocore::Planners::UserPlanner do

  include FakeFS::SpecHelpers

  let(:work_dir) { Protocore::WorkDir.new("/") }

  subject(:planner) { described_class.new(work_dir) }

  let(:cluster_state) { { "templates" => {} } }
  let(:cluster_config) { {
    "users" => {
      "tester" => {
        "gecos" => "a tester",
        "source" => "users/tester.yml"
      }
    }
  } }

  let(:tester_template) {
%Q(
ssh_authorized_keys:
  - ssh-rsa ... tester@example.com
groups:
  - sudo
  - docker
)
  }

  def write_source_file(name, content)
    source_path = work_dir.root_path.join("/users/#{ name }.yml")
    FileUtils.mkdir_p(source_path.dirname)
    File.open(source_path.to_s, "w") { |file| file.write(content) }
  end

  describe "#call" do
    it "extracts the user information" do
      write_source_file("tester", tester_template)
      state = planner.call(cluster_config, cluster_state)
      expect(state).to match a_hash_including("templates",
        "users" => {
          "tester" => an_instance_of(Hash)
        }
      )

      expect(state["users"]["tester"]).to_not match a_hash_including("source")
      expect(state["users"]["tester"]).to match a_hash_including(
        "name" => "tester",
        "gecos" => "a tester"
      )

      expect(state["users"]["tester"]["groups"]).to include("sudo", "docker")
      expect(state["users"]["tester"]["ssh_authorized_keys"]).to include("ssh-rsa ... tester@example.com")
    end
  end

end
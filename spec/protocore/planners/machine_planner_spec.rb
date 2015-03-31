RSpec.describe Protocore::Planners::MachinePlanner do

  include FakeFS::SpecHelpers

  let(:work_dir) { Protocore::WorkDir.new("/") }

  subject(:planner) { described_class.new(work_dir) }

  let(:cluster_state) { {
    "templates" => {
      "default" => {
        "users" => [ "tester" ],
        "files" => [ { "path" => "/etc/env/app.env", "content" => "FOO=BAR\n" } ],
        "units" => [ { "name" => "app.service", "content" => "[Unit]\nDescription=App unit\n" } ]
      }
    }
  } }

  let(:cluster_config) { {
    "machines" => {
      "app.1" => {
        "host" => "10.0.0.1",
        "template" => "default",
        "trust" => [ "CA_RSA" ],
        "units" => [ { "name" => "other.service", "content" => "[Unit]\nDescription=Other unit\n" } ] },
      "app.2" => {
        "host" => "10.0.0.2",
        "template" => "default",
        "trust" => [ "CA_DSA" ],
        "files" => [ { "path" => "/etc/env/other.env", "source" => "files/other.env" } ]
      }
    }
  } }

  describe "#call" do

    it "plans the machines information based on a template" do
      state = planner.call(cluster_config, cluster_state)
      expect(state).to match a_hash_including("templates", "machines" => {
        "app.1" => an_instance_of(Hash),
        "app.2" => an_instance_of(Hash)
      })

      state["machines"].each do |id, machine|
        expect(machine.keys).to_not include "template"
        expect(machine).to match a_hash_including("certs", "files", "units", "trust",
          "host" => /10\.0\.0\.\d/,
          "users" => [ "tester" ],
        )
      end

      expect(state["machines"]["app.1"]).to match a_hash_including(
        "trust" => [ "CA_RSA" ],
        "files" => [
          { "path" => "/etc/env/app.env", "content" => "FOO=BAR\n" }
        ],
        "units" => [
          { "name" => "app.service", "content" => "[Unit]\nDescription=App unit\n" },
          { "name" => "other.service", "content" => "[Unit]\nDescription=Other unit\n" }
        ]
      )

      expect(state["machines"]["app.2"]).to match a_hash_including(
        "trust" => [ "CA_DSA" ],
        "files" => [
          { "path" => "/etc/env/app.env", "content" => "FOO=BAR\n" },
          { "path" => "/etc/env/other.env", "source" => "files/other.env" },
        ],
        "units" => [
          { "name" => "app.service", "content" => "[Unit]\nDescription=App unit\n" }
        ]
      )
    end

  end

end
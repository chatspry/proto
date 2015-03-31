RSpec.describe Protocore::Planners::TemplatePlanner do

  include FakeFS::SpecHelpers

  let(:work_dir) { Protocore::WorkDir.new("/") }

  subject(:planner) { described_class.new(work_dir) }

  let(:cluster_state) { { "authorities" => {} } }
  let(:cluster_config) { {
    "templates" => {
      "default" => {
        "users" => ["tester", "other"],
        "trust" => ["CA_DSA"],
        "source" => "templates/default.yml"
      }
    }
  } }

  let(:default_template) {
    %Q(
      users:
        - zeeraw
        - other
      trust:
        - CA_RSA
      certs:
        - authority: CA_RSA
          signature: SHA512
          bits: 1024
          days: 3650
      files:
        - path: /etc/env/app.env
          permissions: 0644
          owner: root:root
          source: files/app.env
          content: |
            FOO=BAR

      units:
        - name: app.service
          enable: true
          mask: false
          runtime: false
          command: start
          source: units/app.service
          content: |
            [Unit]
            Description=This is inline config
    )
  }

  def write_source_file(name, content)
    source_path = work_dir.root_path.join("/templates/#{ name }.yml")
    FileUtils.mkdir_p(source_path.dirname)
    File.open(source_path.to_s, "w") { |file| file.write(content) }
  end

  describe "#call" do
    it "plans the template information" do
      write_source_file("default", default_template)
      state = planner.call(cluster_config, cluster_state)
      expect(state).to match a_hash_including("authorities", "templates" => { "default" => an_instance_of(Hash) })

      template = state["templates"]["default"]
      expect(template).to_not match a_hash_including("source")
      expect(template).to match a_hash_including("certs", "trust", "users", "files", "units")
      expect(template["certs"]).to match a_hash_including(
        "authority" => "CA_RSA",
        "signature" => "SHA512",
        "bits" => 1024,
        "days" => 3650
      )

      expect(template["files"][0]).to match a_hash_including(
        "path" => "/etc/env/app.env",
        "permissions" => 0644,
        "owner" => "root:root",
        "source" => "files/app.env",
        "content" => "FOO=BAR\n"
      )

      expect(template["units"][0]).to match a_hash_including(
        "name" => "app.service",
        "enable" => true,
        "mask" => false,
        "runtime" => false,
        "command" => "start",
        "source" => "units/app.service",
        "content" => "[Unit]\nDescription=This is inline config\n"
      )

      expect(template["trust"]).to eq ["CA_RSA", "CA_DSA"]
      expect(template["users"]).to eq ["zeeraw", "other", "tester"]
    end
  end

end
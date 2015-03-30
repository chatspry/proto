RSpec.describe Protocore::Plan do

  let(:work_dir) { Protocore::WorkDir.new(Pathname(__FILE__).join("../../fixtures/example")) }

  subject(:plan) { described_class.new(work_dir) }

  describe "#config" do
    it "loads the config and pass it through extractors" do
      config = plan.config
      expect(config).to be_kind_of Hash
      expect(config["authorities"]).to match a_hash_including({
        "CA_RSA" => an_instance_of(Protocore::Authority),
        "CA_DSA" => an_instance_of(Protocore::Authority),
      })
    end
  end

  describe "#key_store" do
    it { expect(plan.key_store).to be_kind_of Protocore::KeyStore }
  end

  describe "#cert_store" do
    it { expect(plan.cert_store).to be_kind_of Protocore::CertStore }
  end

end
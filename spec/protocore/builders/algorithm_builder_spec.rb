class Protocore::AlgorithmBuilderTester
  include Protocore::Builders::AlgorithmBuilder
end

RSpec.describe Protocore::Builders::AlgorithmBuilder do

  subject { Protocore::AlgorithmBuilderTester.new }

  describe "#build_algorithm" do
    it { expect(subject.build_algorithm("rsa")).to eq OpenSSL::PKey::RSA }
    it { expect(subject.build_algorithm("dsa")).to eq OpenSSL::PKey::DSA }
    it { expect { subject.build_algorithm("other") }.to raise_error(NotImplementedError) }
  end

end
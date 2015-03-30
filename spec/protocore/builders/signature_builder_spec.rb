class Protocore::SignatureBuilderTester
  include Protocore::Builders::SignatureBuilder
end

RSpec.describe Protocore::Builders::SignatureBuilder do

  subject { Protocore::SignatureBuilderTester.new }

  describe "#build_signature" do
    it { expect(subject.build_signature("sha1")).to eq OpenSSL::Digest::SHA1 }
    it { expect(subject.build_signature("sha224")).to eq OpenSSL::Digest::SHA224 }
    it { expect(subject.build_signature("sha256")).to eq OpenSSL::Digest::SHA256 }
    it { expect(subject.build_signature("sha384")).to eq OpenSSL::Digest::SHA384 }
    it { expect(subject.build_signature("sha512")).to eq OpenSSL::Digest::SHA512 }
    it { expect { subject.build_signature("other") }.to raise_error(NotImplementedError) }
  end

end
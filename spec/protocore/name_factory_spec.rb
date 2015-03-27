RSpec.describe Protocore::NameFactory do

  subject { described_class.new(
    "country" => "GB",
    "state" => nil,
    "city" => "London",
    "organization" => "Test Ltd.",
    "department" => "Testing",
    "common_name" => "test.local",
    "email" => "test@example.com"
  ) }

  describe "#call" do

    it "returns a X509 instance with the base values" do
      details = subject.call
      expect(details).to be_kind_of OpenSSL::X509::Name
      expect(details.to_s).to eq "/C=GB/L=London/O=Test Ltd./OU=Testing/CN=test.local/emailAddress=test@example.com"
    end

    it "returns a X509 instance with extra values" do
      details = subject.call({"city" => "Bath"})
      expect(details).to be_kind_of OpenSSL::X509::Name
      expect(details.to_s).to eq "/C=GB/L=Bath/O=Test Ltd./OU=Testing/CN=test.local/emailAddress=test@example.com"
    end

  end

end
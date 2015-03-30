RSpec.describe Protocore::Engines::FileEngine do

  include FakeFS::SpecHelpers

  subject(:engine) { described_class.new }

  describe "#commit" do

    it "persists all cached files to the file system" do
      engine.set("/1", "one")
      engine.set("/2", "two")
      engine.set("/3", "three")
      expect { engine.commit }.to change {
        File.exists?("/1") &&
        File.exists?("/2") &&
        File.exists?("/3")
      }.from(false).to(true)
    end

  end

  describe "#get" do

    it "retrieves a file from the file system" do
      engine.set("/foo", "bar")
      expect( engine.get("/foo") ).to eq "bar"
    end

    it "retrieves a file from the file system and calls block" do
      engine.set("/baz", "buz")
      expect( engine.get("/baz") { |content| content + content } ).to eq "buzbuz"
    end

    it "returns nil if there is no file on the file system" do
      expect( engine.get("/foo") ).to eq nil
    end

  end

  describe "#set" do

    it "persists the file in the cache" do
      expect { engine.set("/hello", "world") }.to change { engine.cache["/hello"] }.to "world"
    end

  end

  describe "#exists?" do

    it "returns true if there is a file on the file system" do
      File.open("/hello", "w") { |file| "world" }
      expect(engine.exists?("/hello")).to eq true
    end

    it "returns false if there is no file in the file system" do
      FileUtils.rm_rf("/hello")
      expect(engine.exists?("/hello")).to eq false
    end

  end


end
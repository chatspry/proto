require "protocore/engines/file_engine"

module Protocore
  class KeyStore

    attr_reader :path, :engine

    def initialize(work_dir)
      @engine = Protocore::Engines::FileEngine.new
      @path = work_dir.keys_path
    end

    def find_or_create(*namespace, bits: 2048, algorithm: OpenSSL::PKey::RSA)
      file_path = path.join(*namespace).to_s + ".pem"
      find(file_path, algorithm) || create(file_path, bits, algorithm)
    end

    def find(file_path, algorithm)
      engine.get(file_path) { |pem| algorithm.new(pem) }
    end

    def create(file_path, bits, algorithm)
      algorithm.new(bits).tap { |key| engine.set(file_path, key.to_pem) }
    end

  end
end
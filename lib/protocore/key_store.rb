require "openssl"

module Protocore
  class KeyStore

    attr_reader :path

    def initialize(work_dir)
      @path = work_dir.keys_path
    end

    def find_or_create(*namespace, bits: 2048, algorithm: OpenSSL::PKey::RSA)
      file_path = path.join(*namespace).to_s + ".pem"
      find(file_path, algorithm) || create(file_path, bits, algorithm)
    end

  private

    def find(file_path, algorithm)
      key = algorithm.new(File.read(file_path)) if File.exists?(file_path)
    end

    def create(file_path, bits, algorithm)
      algorithm.new(bits).tap do |key|
        FileUtils.mkdir_p Pathname(file_path).dirname
        File.open(file_path, "w") { |f| f.write key.to_pem }
      end
    end

  end
end
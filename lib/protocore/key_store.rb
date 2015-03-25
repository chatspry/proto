require "openssl"

module Protocore
  class KeyStore

    attr_reader :file_path

    def initialize(work_dir, name)
      @name = name
      @work_dir = Pathname(work_dir).expand_path
      @file_path = @work_dir.join(@name + ".pem")
    end

    def find_or_create(bits: 2048, algorithm: OpenSSL::PKey::RSA)
      find(algorithm) || create(bits, algorithm)
    end

  private

    def find(algorithm)
      key = algorithm.new(File.read(@file_path)) if File.exists?(@file_path)
    end

    def create(bits, algorithm)
      key = algorithm.new(bits)
      FileUtils.mkdir_p(@work_dir) && File.open(@file_path, "w") { |f| f.write key.to_pem }
      return key
    end

  end
end
require "openssl"

module Protocore
  class KeyStore

    attr_reader :key, :file_path

    def initialize(work_dir, name, bits: 2048, algorithm: "rsa")
      @name = name
      @bits = bits
      @work_dir = Pathname(work_dir).expand_path
      @file_path = @work_dir.join(@name + ".pem")
      @key_class = case algorithm
      when "rsa" then OpenSSL::PKey::RSA
      when "dsa" then OpenSSL::PKey::DSA
      else raise ArgumentError, "key type not supported"
      end
    end

    def find_or_create
      find || create unless key
      return key
    end

  private

    def find
      @key = @key_class.new(File.read(@file_path)) if File.exists?(@file_path)
    end

    def create
      @key = @key_class.new(@bits)
      FileUtils.mkdir_p(@work_dir) && File.open(@file_path, "w") { |f| f.write @key.to_pem }
    end

  end
end
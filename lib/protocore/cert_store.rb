module Protocore
  class CertStore

    attr_reader :path

    def initialize(context)
      @path = context.certs_path
    end

    def find_or_create(*namespace, &blk)
      file_path = path.join(*namespace).to_s + ".crt"
      find(file_path) || create(file_path, yield)
    end

  private

    def find(file_path)
      @key = OpenSSL::X509::Certificate.new(File.read(file_path.to_s)) if File.exists?(file_path.to_s)
    end

    def create(file_path, cert)
      cert.tap do |cert|
        FileUtils.mkdir_p Pathname(file_path).dirname.to_s
        File.open(file_path.to_s, "w") { |f| f.write cert.to_pem }
      end
    end

  end
end
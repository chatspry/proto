require "protocore/engines/file_engine"

module Protocore
  class CertStore

    attr_reader :path, :engine

    def initialize(work_dir)
      @engine = Protocore::Engines::FileEngine.new
      @path = work_dir.certs_path
    end

    def find_or_create(*namespace, &blk)
      file_path = path.join(*namespace).to_s + ".crt"
      find(file_path) || create(file_path, yield)
    end

    def find(file_path)
      engine.get(file_path) { |pem| OpenSSL::X509::Certificate.new(pem) }
    end

    def create(file_path, cert)
      cert.tap { |cert| engine.set(file_path, cert.to_pem) }
    end

  end
end
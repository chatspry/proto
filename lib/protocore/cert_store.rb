module Protocore
  class CertStore

    attr_reader :file_path

    def initialize(work_dir, name)
      @name = name
      @work_dir = Pathname(work_dir).expand_path
      @file_path = @work_dir.join(name + ".crt")
    end

    def find_or_create(&blk)
      find || create(yield)
    end

  private

    def find
      @key = OpenSSL::X509::Certificate.new(File.read(@file_path)) if File.exists?(@file_path)
    end

    def create(cert)
      FileUtils.mkdir_p(@work_dir) && File.open(@file_path, "w") { |f| f.write cert.to_pem }
      cert
    end

  end
end
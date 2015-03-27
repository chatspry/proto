module Protocore
  class WorkDir

    def initialize(directory, options = {})
      @options = options
      @directory = Pathname.new(directory)
    end

    def config_file_path
      @config_file_path ||= root_path.join(@options.fetch(:cluster_config, "cluster_config.yml")).to_s
    end

    def root_path
      @root_path ||= @directory
    end

    def state_path
      @state_path ||= @directory.join(root_path, ".protocore")
    end

    def certs_path
      @certs_path ||= @directory.join(state_path, "certs")
    end

    def keys_path
      @keys_path ||= @directory.join(state_path, "keys")
    end

    def user
      @options[:user]
    end

    def manifest!
      FileUtils.mkdir_p(keys_path)
      FileUtils.mkdir_p(certs_path)
      FileUtils.touch(config_file_path)
      return self
    end

  end
end
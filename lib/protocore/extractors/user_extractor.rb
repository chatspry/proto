module Protocore
  module Extractors
    class UserExtractor

      def initialize(work_dir, key_store, cert_store)
        @work_dir = work_dir
        @key_store = key_store
        @cert_store = cert_store
      end

      def call(config)
        config.tap do |config|
          config["users"] = config.fetch("users", {}).inject({}) do |users, (name, options)|
            users.tap { |a| a[name] = build_user(name, options) }
          end
        end
      end

    private

      def build_user(name, options)
        { "name" => name }.merge(options).tap do |options|
          if file_path = options.delete("source")
            options.merge! load_source(file_path)
          end
        end
      end

      def load_source(file_path)
        path = @work_dir.root_path.join(file_path).expand_path.to_s
        YAML.load File.read path if File.exists? path
      end

    end
  end
end
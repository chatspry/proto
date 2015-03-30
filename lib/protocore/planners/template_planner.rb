module Protocore
  module Planners
    class TemplatePlanner

      def initialize(work_dir)
        @work_dir = work_dir
      end

      def call(config)
        config.tap do |config|
          config["templates"] = config.fetch("templates", {}).inject({}) do |users, (name, options)|
            users.tap { |a| a[name] = plan_template(name, options) }
          end
        end
      end

    private

      def plan_template(name, options)
        options.tap do |options|
          if file_path = options.delete("source")
            source = load_source(file_path)
            %w(users trust certs files units).each do |f|
              options[f] = merge_field(f, source, options)
            end
          end
        end
      end

      def load_source(file_path)
        path = @work_dir.root_path.join(file_path).expand_path.to_s
        YAML.load File.read path if File.exists? path
      end

      def merge_field(name, source, options, default = [])
        [source, options].map { |o| o.fetch(name, default) }.inject(&:+).uniq
      end

    end
  end
end
module Protocore
  module Planners
    class TemplatePlanner

      def initialize(work_dir)
        @work_dir = work_dir
      end

      def call(config, state)
        state.dup.tap do |state|
          state["templates"] = config.fetch("templates", {}).inject({}) do |users, (name, user)|
            users.tap { |a| a[name] = plan_template(name, user) }
          end
        end
      end

    private

      def plan_template(name, user)
        user.tap do |user|
          if file_path = user.delete("source")
            source = load_source(file_path)
            %w(users trust certs files units).each do |f|
              user[f] = merge_field(f, source, user)
            end
          end
        end
      end

      def load_source(file_path)
        path = @work_dir.root_path.join(file_path).expand_path.to_s
        YAML.load File.read path if File.exists? path
      end

      def merge_field(name, source, user, default = [])
        [source, user].map { |o| o.fetch(name, default) }.inject(&:+).uniq
      end

    end
  end
end
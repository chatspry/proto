module Protocore
  module Planners
    class UserPlanner

      def initialize(work_dir)
        @work_dir = work_dir
      end

      def call(config, state)
        state.dup.tap do |state|
          state["users"] = config.fetch("users", {}).inject({}) do |users, (name, user)|
            users.tap { |hash| hash[name] = plan_user(name, user) }
          end
        end
      end

    private

      def plan_user(name, options)
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
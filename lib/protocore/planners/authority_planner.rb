module Protocore
  module Planners
    class AuthorityPlanner

      def initialize(work_dir)
        @work_dir = work_dir
      end

      def call(config, state)
        state.dup.tap do |state|
          state["authorities"] = config.fetch("authorities", {}).inject({}) do |authorities, (name, authority)|
            authorities.tap { |hash| hash[name] = plan_authority(name, authority) }
          end
        end
      end

    private

      def plan_authority(name, authority)
        authority.tap do |authority|
          %w(bits days).each do |field|
            authority[field] = Integer(authority[field])
          end
        end
      end

    end
  end
end
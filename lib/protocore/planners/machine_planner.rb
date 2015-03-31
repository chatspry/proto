module Protocore
  module Planners
    class MachinePlanner

      def initialize(work_dir)
        @work_dir = work_dir
      end

      def call(config, state)
        state.dup.tap do |state|
          state["machines"] = config.fetch("machines", {}).inject({}) do |machines, (name, machine)|
            machines.tap do |hash|
              hash[name] = plan_machine(state, machine)
            end
          end
        end
      end

    private

      def plan_machine(state, machine)
        machine.tap do |machine|
          template_name = machine.delete("template")
          template = state.fetch("templates", {}).fetch(template_name, {})
          %w(users trust certs files units).each do |field|
            machine[field] = merge_array_field(field, template, machine)
          end
        end
      end

      def merge_array_field(name, template, machine)
        [ template, machine ].map { |c| c.fetch(name, []) }.inject(&:+)
      end

    end
  end
end
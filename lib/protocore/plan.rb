module Protocore
  class Plan

    PLANNERS = [
      Protocore::Planners::AuthorityPlanner,
      Protocore::Planners::UserPlanner,
      Protocore::Planners::TemplatePlanner,
      Protocore::Planners::MachinePlanner
    ]

    attr_reader :work_dir

    def initialize(work_dir)
      @work_dir = work_dir
    end

    def state
      return @state if @state
      @state = {
        "timestamp" => (Time.now.to_i * 1000),
        "state" => construct_state(load_config)
      }
    end

  private

    def construct_state(config)
      PLANNERS.inject({}) { |state, planner| planner.new(@work_dir).call(config, state) }
    end

    def load_config
      Dir[ @work_dir.root_path.join("*") ].inject({}) do |content, file_path|
        content.merge! load file_path if check file_path
        return content
      end
    end

    def load(file_path)
      YAML.load File.read(file_path).
        gsub(/(?<=\:\s)(off)(?=\n)/, '"\1"').
        gsub(/(?<=\:\s)(0\d+)(?=\n)/, '"\1"')
    end

    def check(file_path)
      File.file?(file_path) && File.open(file_path, &:readline).eql?("#cluster-config\n")
    end

  end
end
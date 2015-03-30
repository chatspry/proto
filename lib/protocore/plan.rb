module Protocore
  class Plan

    attr_reader :work_dir

    def initialize(work_dir)
      @work_dir = work_dir
    end

    def config
      @config ||= construct
    end

  private

    def planners
      [
        Protocore::Planners::UserPlanner,
        Protocore::Planners::TemplatePlanner
      ]
    end

    def construct
      planners.inject(load_all_config) { |c, e| e.new(@work_dir).call(c) }
    end

    def load_all_config
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
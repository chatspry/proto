require "thor"

module Protocore

  class Cli < Thor

    desc "plan [HOSTNAME]", "Plan your cluster and print cloud-config for all host"
    long_desc <<-LONGDESC
      By planning you evaluate a cluster-config file and print all your host configuration to /dev/stdout

      You can specify a specific path to your cluster-config yaml file:

      $ protocore plan --config ./my/path/to/cluster-config.yaml
    LONGDESC
    option :config, default: "./cluster-config.yaml", aliases: ["-c"]
    def plan(hostname=nil)
      require "pathname"
      path = Pathname.new(ENV["PWD"]).join(options[:config])
      hosts = Protocore.load(path)
      hosts.select! { |host| host.name == hostname } if hostname
      hosts.each do |host|
        puts host.to_yaml + "\n"
      end
    end

  end

end
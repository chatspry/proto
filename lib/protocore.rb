require "protocore/version"
require "protocore/description"

require "protocore/work_dir"
require "protocore/details_factory"
require "protocore/cert_factory"
require "protocore/cert_store"
require "protocore/key_store"
require "protocore/authority"

require "protocore/extractors"
require "protocore/planners/user_planner"

require "protocore/builders/signature_builder"
require "protocore/builders/algorithm_builder"
require "protocore/builders/authority_builder"

require "protocore/plan"

require "yaml"

module Protocore

  def self.load(path)
    parse read path
  end

  def self.read(path)
    File.read(path).
      gsub(/(?<=\:\s)(off)(?=\n)/, '"\1"')
  end

  def self.parse(yaml)
    hosts = YAML.load(yaml)["hosts"]
    raise "could not parse 'hosts' key is missing" if hosts == nil
    return hosts.map { |host| Host.new(host) }
  end

  class Host

    attr_reader :structure
    attr_reader :name

    def initialize(structure)
      raise ArgumentError, "structure cannot be nil" unless structure
      @structure = structure
      @name = structure["hostname"]
    end

    def to_yaml
      @yaml ||= structure.to_yaml.
        gsub(/(?<=\:\s)\"(.*)\"(?=\n)/i, '\1').
        gsub(/(?<=\:\s)\'(off)\'(?=\n)/, '\1').
        gsub(/^---/,"#cloud-config")
    end

  end

end

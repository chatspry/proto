# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "protocore/version"
require "protocore/description"

Gem::Specification.new do |spec|
  spec.name          = "protocore"
  spec.version       = Protocore::VERSION
  spec.authors       = ["Philip Vieira"]
  spec.email         = ["philip@chatspry.com"]
  spec.summary       = Protocore::DESCRIPTION
  spec.description   = %q{Create configuration files for your whole CoreOS cluster based on templates}
  spec.homepage      = "https://github.com/chatspry/protocore"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end

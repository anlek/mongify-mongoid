# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongify/mongoid/version'

Gem::Specification.new do |spec|
  spec.name          = "mongify-mongoid"
  spec.version       = Mongify::Mongoid::VERSION
  spec.authors       = ["Andrew Kalek", "Afolabi Badmos"]
  spec.email         = ["andrew.kalek@anlek.com", "afolabi@badmos.com"]
  spec.description   = %q{Generates Mongoid Models from the Mongify translation file}
  spec.summary       = %q{Generates Mongoid Models from the Mongify translation file}
  spec.homepage      = "https://github.com/anlek/mongify-mongoid"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = [
    "CHANGELOG.md",
    "README.md"
  ]

  spec.add_dependency "mongify"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'redcarpet'
end

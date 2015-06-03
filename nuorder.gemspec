# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nuorder/version'

Gem::Specification.new do |spec|
  spec.name          = "nuorder"
  spec.version       = Nuorder::VERSION
  spec.authors       = ["Springboard Retail"]
  spec.email         = ["jason.stotz@gmail.com"]
  spec.summary       = %q{Library that wraps up the communication with the API services from Nuorder.com}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec','~> 3.2.0'
  spec.add_development_dependency 'byebug', '~> 3.5.1'
  spec.add_development_dependency 'vcr', '~> 2.9.3'
  spec.add_development_dependency 'dotenv', '~> 1.0.2'

  spec.add_runtime_dependency 'faraday', '~> 0.9.1'
  spec.add_runtime_dependency 'excon', '~> 0.45.3'
  spec.add_runtime_dependency 'faraday_middleware-multi_json', '~> 0.0.6'
end

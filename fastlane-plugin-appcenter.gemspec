lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/appcenter/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-appcenter'
  spec.version       = Fastlane::Appcenter::VERSION
  spec.author        = 'Microsoft Corporation'

  spec.summary       = 'Fastlane plugin for App Center'
  spec.homepage      = "https://github.com/microsoft/fastlane-plugin-appcenter"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  # spec.add_dependency 'your-dependency', '~> 1.0.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'fastlane', '>= 2.96.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '>= 0.77.0'
  spec.add_development_dependency 'webmock'
end

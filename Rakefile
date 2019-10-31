require 'bundler/gem_tasks'

# Enable strict mode for tests
ENV['APPCENTER_STRICT_MODE'] = "true"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:spec, :rubocop]

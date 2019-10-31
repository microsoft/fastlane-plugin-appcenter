require 'bundler/gem_tasks'

# Enable strict mode for tests
ENV['APPCENTER_STRICT_MODE'] = "true"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
RSpec::Core::RakeTask.new(:spec_ci) do |task, args|
  task.rspec_opts = %w(--format RspecJunitFormatter --out test-result.xml)
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: [:spec, :rubocop]
task ci: [:spec_ci, :rubocop]

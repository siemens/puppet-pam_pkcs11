require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/version'
require 'puppet/vendor/semantic/lib/semantic' unless Puppet.version.to_f < 3.6
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'

# These gems aren't always present, for instance on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2')
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
end

# Coverage from puppetlabs-spec-helper requires rcov which
# doesn't work in anything since 1.8.7
Rake::Task[:coverage].clear

PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.disable_80chars

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc 'Populate CONTRIBUTORS file'
task :contributors do
  system("git log --format='%aN <%aE>' | sort -u > CONTRIBUTORS")
end

desc 'Run syntax, lint, and spec tests.'
task :test => [
  :metadata_lint,
  :syntax,
  :lint,
  :spec,
]

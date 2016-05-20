require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'

include RspecPuppetFacts

# require 'simplecov'
# require 'simplecov-console'
#
# SimpleCov.start do
#   add_filter '/bundle'
#   add_filter '/pkg'
#   add_filter '/spec'
#   add_filter '/vendor'
#   formatter SimpleCov::Formatter::MultiFormatter.new([
#     SimpleCov::Formatter::HTMLFormatter,
#     SimpleCov::Formatter::Console,
#   ])
# end

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |config|
  config.add_formatter 'documentation'
  config.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.hiera_config = File.join(fixture_path, 'hiera.yaml')
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
  config.tty = true
  config.fail_fast = true
end

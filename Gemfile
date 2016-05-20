source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gem 'rake', '< 11',                      :require => false
gem 'puppet', ENV['PUPPET_GEM_VERSION'], :require => false
gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false

group :test do
  # https://github.com/rspec/rspec-core/issues/1864
  gem 'rspec', '< 3.2.0', 'platforms' => ['ruby_18'],              :require => false
  gem 'puppetlabs_spec_helper',                                    :require => false
  gem 'puppet-syntax',                                             :require => false
  gem 'rspec-puppet', '~> 2.2',                                    :require => false
  gem 'rspec-puppet-facts',                                        :require => false
  gem 'metadata-json-lint',                                        :require => false
  gem 'puppet-lint', '>= 1.1.0',                                   :require => false
  gem 'puppet-lint-absolute_classname-check',                      :require => false
  gem 'puppet-lint-leading_zero-check',                            :require => false
  gem 'puppet-lint-trailing_comma-check',                          :require => false
  gem 'puppet-lint-version_comparison-check',                      :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check', :require => false
  gem 'puppet-lint-unquoted_string-check',                         :require => false
  gem 'puppet-lint-resource_reference_syntax',                     :require => false
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2')
    gem 'rubocop', :require => false
  end
end

group :development do
  gem 'travis',                                           :require => false
  gem 'travis-lint',                                      :require => false
  gem 'puppet-blacksmith',                                :require => false
  gem 'guard-rake',                                       :require => false
  gem 'highline',    '< 1.7', 'platforms' => ['ruby_18'], :require => false
  gem 'addressable', '< 2.4', 'platforms' => ['ruby_18'], :require => false
  if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2')
    gem 'listen', '< 3.1', :require => false
  end
end

group :system_tests do
  gem 'beaker',                       :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'vagrant-wrapper',              :require => false
end

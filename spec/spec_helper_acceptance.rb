require 'beaker-rspec'
require 'beaker/puppet_install_helper'

ENV['BEAKER_provision'] == 'no' ||  run_puppet_install_helper

UNSUPPORTED_PLATFORMS = ['Windows', 'Solaris', 'AIX'].freeze

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # detect the situation where PUP-5016 is triggered and skip the idempotency tests in that case
  # also note how fact('puppetversion') is not available because of PUP-4359
  if fact('osfamily') == 'Debian' && fact('operatingsystemmajrelease') == '8' && shell('puppet --version').stdout =~ %r{^4\.2}
    c.filter_run_excluding skip_pup_5016: true
  end

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'pam_pkcs11')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib', '--version', '4.8.0')
    end
  end
end

shared_examples 'an idempotent resource' do
  it 'must apply with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'must apply a second time without changes', :skip_pup_5016 do
    apply_manifest(pp, catch_changes: true)
  end
end

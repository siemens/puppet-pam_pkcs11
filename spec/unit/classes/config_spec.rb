require 'spec_helper'

describe 'pam_pkcs11::config', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:fixture_path) { File.expand_path(File.join(__FILE__, '..', '..', '..', 'fixtures')) }

      let(:os_files_path) do
        case facts[:os]['family']
        when 'Gentoo'
          'Gentoo'
        when 'Debian'
          'Debian'
        when 'RedHat', 'Suse'
          if facts[:os].fetch('architecture', facts[:architecture]).match?(%r{i[3-6]86})
            facts[:os]['release']['major'] == '5' ? ['RedHat', '32', 'RedHat-5'] : ['RedHat', '32']
          else
            facts[:os]['release']['major'] == '5' ? ['RedHat', '64', 'RedHat-5'] : ['RedHat', '64']
          end
        end
      end

      let(:default_pam_pkcs11_conf) do
        File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam_pkcs11.conf')).read
      end

      context 'without any parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('pam_pkcs11::config').that_requires('Class[pam_pkcs11::install]') }

        it do
          is_expected.to contain_file('/etc/pam_pkcs11').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
        end

        it do
          is_expected.to contain_file('pam_pkcs11.conf')
            .with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0600',
              'path'   => '/etc/pam_pkcs11/pam_pkcs11.conf',
            )
            .with_content(default_pam_pkcs11_conf)
            .that_requires('File[/etc/pam_pkcs11]')
        end
      end # 'without any parameters'
    end
  end
end

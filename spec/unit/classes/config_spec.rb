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
          case facts[:os]['name']
          when 'Debian'
            case facts[:os]['release']['major']
            when '9', '10'
              'Debian-old'
            else
              'Debian'
            end
          when 'Ubuntu'
            case facts[:os]['release']['major']
            when '18.04', '20.04'
              'Debian-old'
            else
              'Debian'
            end
          else
            'invalid-config_spec'
          end
        when 'RedHat', 'Suse'
          if facts[:os].fetch('architecture', facts[:architecture]).match?(%r{i[3-6]86})
            ['RedHat', '32']
          else
            ['RedHat', '64']
          end
        end
      end

      let(:default_pam_pkcs11_conf) do
        File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam_pkcs11.conf')).read
      end

      if facts[:os]['family'] == 'Debian'
        let(:default_pam_config_pkcs11) do
          File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam-config.conf')).read
        end
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
          is_expected.to contain_file('/etc/pam_pkcs11/pam_pkcs11.conf')
            .with(
              'ensure' => 'file',
              'owner'  => 'root',
              'group'  => 'root',
              'mode'   => '0600',
            )
            .with_content(default_pam_pkcs11_conf)
            .that_requires('File[/etc/pam_pkcs11]')
        end

        if facts[:os]['family'] == 'Debian'
          it do
            is_expected.to contain_file('/usr/share/pam-configs')
              .with(
                'ensure' => 'directory',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0755',
              )
          end

          it do
            is_expected.to contain_file('/usr/share/pam-configs/pkcs11')
              .with(
                'ensure' => 'file',
                'owner'  => 'root',
                'group'  => 'root',
                'mode'   => '0644',
              )
              .with_content(default_pam_config_pkcs11)
              .that_requires('File[/usr/share/pam-configs]')
          end
        end
      end # 'without any parameters'
    end
  end
end

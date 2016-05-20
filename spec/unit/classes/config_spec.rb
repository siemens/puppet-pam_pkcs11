require 'spec_helper'

describe 'pam_pkcs11::config', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:fixture_path) { File.expand_path(File.join(__FILE__, '..', '..', '..', 'fixtures')) }

      let(:os_files_path) do
        case facts[:osfamily]
        when 'Gentoo'
          'Gentoo'
        when 'Debian'
          'Debian'
        when 'RedHat', 'Suse'
          if facts[:architecture] =~ /i[3-6]86/
            if (facts[:operatingsystem] =~ /RedHat|CentOS|Scientific|OracleLinux/) && (facts[:operatingsystemmajrelease] == '5')
              %w(RedHat 32 RedHat-5)
            else
              %w(RedHat 32)
            end
          else
            if (facts[:operatingsystem] =~ /RedHat|CentOS|Scientific|OracleLinux/) && (facts[:operatingsystemmajrelease] == '5')
              %w(RedHat 64 RedHat-5)
            else
              %w(RedHat 64)
            end
          end
        end
      end

      let(:default_pam_pkcs11_conf) do
        File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam_pkcs11.conf')).read
      end

      context 'without any parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('pam_pkcs11::config').that_requires('pam_pkcs11::install') }

        it do
          is_expected.to contain_file('/etc/pam_pkcs11').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755'
          )
        end

        it do
          is_expected.to contain_file('pam_pkcs11.conf').with(
            'ensure' => 'file',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0600',
            'path'   => '/etc/pam_pkcs11/pam_pkcs11.conf'
          ).with_content(default_pam_pkcs11_conf).
            that_requires('File[/etc/pam_pkcs11]')
        end
      end # 'without any parameters'
    end
  end

  context 'on all supported operating systems' do
    let(:facts) do
      {
        :osfamily                  => 'Gentoo',
        :operatingsystem           => 'Gentoo',
        :operatingsystemmajrelease => '4',
      }
    end
  end

  context 'on an unsupported operating system' do
    let(:facts) do
      {
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }
    end

    context 'without any parameters' do
    end
  end
end

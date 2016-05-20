require 'spec_helper'

describe 'pam_pkcs11', :type => :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:package_name) do
        case facts[:osfamily]
        when 'Gentoo'
          'sys-auth/pam_pkcs11'
        when 'Debian'
          'libpam-pkcs11'
        else
          'pam_pkcs11'
        end
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
            facts[:operatingsystemmajrelease] == '5' ? %w(RedHat 32 RedHat-5) : %w(RedHat 32)
          else
            facts[:operatingsystemmajrelease] == '5' ? %w(RedHat 64 RedHat-5) : %w(RedHat 64)
          end
        end
      end

      let(:default_pam_pkcs11_conf) do
        File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam_pkcs11.conf')).read
      end

      let(:default_pkcs11_eventmgr_conf) do
        File.open(File.join(fixture_path, 'default_files', os_files_path, 'pkcs11_eventmgr.conf')).read
      end

      context 'without any parameters' do
        #
        # self
        #
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('pam_pkcs11') }
        it { is_expected.to contain_class('pam_pkcs11::params') }
        it { is_expected.to contain_class('pam_pkcs11::install') }
        it { is_expected.to contain_class('pam_pkcs11::config') }
        it { is_expected.to contain_class('pam_pkcs11::pkcs11_eventmgr') }

        #
        # pam_pkcs11::install
        #
        it { is_expected.to contain_package(package_name).with_ensure('present') }

        #
        # pam_pkcs11::config
        #
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

        #
        # pam_pkcs11::pkcs11_eventmgr
        #
        it do
          is_expected.to contain_file('pkcs11_eventmgr.conf').with(
            'ensure'  => 'present',
            'path'    => '/etc/pam_pkcs11/pkcs11_eventmgr.conf',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => default_pkcs11_eventmgr_conf
          )
        end
      end # 'without any parameters'

      context 'when `debug` is set' do
        context 'to `true`' do
          let(:params) { { 'debug' => true } }

          # FIXME: `debug` appears multiple times in the file
          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  debug             = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          # FIXME: `debug` appears multiple times in the file
          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  debug             = false;/) }
        end
      end

      context 'when `nullok` is set' do
        context 'to `true`' do
          let(:params) { { 'nullok' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  nullok            = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  nullok            = false;/) }
        end
      end

      context 'when `use_first_pass` is set' do
        context 'to `true`' do
          let(:params) { { 'use_first_pass' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  use_first_pass    = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  use_first_pass    = false;/) }
        end
      end

      context 'when `try_first_pass` is set' do
        context 'to `true`' do
          let(:params) { { 'try_first_pass' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  try_first_pass    = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  try_first_pass    = false;/) }
        end
      end

      context 'when `use_authtok` is set' do
        context 'to `true`' do
          let(:params) { { 'use_authtok' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  use_authtok       = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  use_authtok       = false;/) }
        end
      end

      context 'when `card_only` is set' do
        context 'to `true`' do
          let(:params) { { 'card_only' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  card_only         = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  card_only         = false;/) }
        end
      end

      context 'when `wait_for_card` is set' do
        context 'to `true`' do
          let(:params) { { 'wait_for_card' => true } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  wait_for_card     = true;/) }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/  wait_for_card     = false;/) }
        end
      end

      context 'when `use_mappers` is set' do
        context 'to a single, supported value' do
          let(:params) { { 'use_mappers' => ['digest'] } }
          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/use_mappers = "digest";/) }
        end

        context 'to a multiple, supported values' do
          let(:params) { { 'use_mappers' => %w(ldap digest) } }

          it { is_expected.to contain_file('pam_pkcs11.conf').with_content(/use_mappers = "ldap, digest";/) }
        end

        context 'to an unsupported value' do
          let(:params) { { 'use_mappers' => ['bad_mapper'] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an unsupported type' do
          let(:params) { { 'use_mappers' => 'digest' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'when `digest_mappings` contains multiple good mappings' do
        let(:params) do
          {
            :digest_mappings => {
              'alice' => '79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF',
              'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
            },
          }
        end

        it do
          is_expected.to contain_file('digest_mapping').
            with_ensure('file').
            with_path('/etc/pam_pkcs11/digest_mapping').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_content(/^79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF -> alice$/).
            with_content(/^DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31 -> bob$/)
        end
      end

      context 'when a fingerprint in in `digest_mappings` is specified as an invalid type' do
        let(:params) do
          {
            :digest_mappings => {
              'alice' => ['79:E7:27:38:59:24:C6:AD:92:E5', 'AA:FA:20:0F:D6:9A:D5:47:87:DF'],
              'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
            },
          }
        end

        it { is_expected.to raise_error(Puppet::Error, /is not a string/) }
      end

      context 'when the first fingerprint in `digest_mappings` is invalid' do
        let(:params) do
          {
            :digest_mappings => {
              'alice' => 'not_a_fingerprint',
              'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
            },
          }
        end

        it { is_expected.to raise_error(Puppet::Error, /does not match/) }
      end

      context 'when the second fingerprint in `digest_mappings` is invalid' do
        let(:params) do
          {
            :digest_mappings => {
              'alice' => '79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF',
              'bob'   => 'not_a_fingerprint',
            },
          }
        end

        it { is_expected.to raise_error(Puppet::Error, /does not match/) }
      end

      context 'when `subject_mappings` contains multiple good mappings' do
        let(:params) do
          {
            :subject_mappings => {
              'alice' => '/C=US/O=Example/OU=People/UID=alice/CN=Alice',
              'bob'   => '/C=US/O=Example/OU=People/UID=bob/CN=Bob',
            },
          }
        end

        it do
          is_expected.to contain_file('subject_mapping').
            with_ensure('file').
            with_path('/etc/pam_pkcs11/subject_mapping').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_content(/^\/C=US\/O=Example\/OU=People\/UID=alice\/CN=Alice -> alice$/).
            with_content(/^\/C=US\/O=Example\/OU=People\/UID=bob\/CN=Bob -> bob$/)
        end
      end

      context 'when a subject in in `subject_mappings` is specified as an invalid type' do
        let(:params) do
          {
            :subject_mappings => {
              'alice' => { 'C' => 'US', 'O' => 'Example', 'OU' => 'People', 'UID' => 'alice', 'CN' => 'Alice' },
              'bob'   => '/C=US/O=Example/OU=People/UID=bob/CN=Bob',
            },
          }
        end

        it { is_expected.to raise_error(Puppet::Error, /is not a string/) }
      end

      context 'when `uid_mappings` contains multiple good mappings' do
        let(:params) do
          {
            :uid_mappings => {
              'alice' => 'alicia',
              'bob'   => 'robert',
            },
          }
        end

        it do
          is_expected.to contain_file('uid_mapping').
            with_ensure('file').
            with_path('/etc/pam_pkcs11/uid_mapping').
            with_owner('root').
            with_group('root').
            with_mode('0600').
            with_content(/^alicia -> alice$/).
            with_content(/^robert -> bob$/)
        end
      end

      context 'when a uid in in `uid_mappings` is specified as an invalid type' do
        let(:params) do
          {
            :uid_mappings => {
              'alice' => ['alicia'],
              'bob' => 'robert',
            },
          }
        end

        it { is_expected.to raise_error(Puppet::Error, /is not a string/) }
      end

      shared_examples_for 'a host with an OpenSSL CA hash link directory' do |sourceselect|
        it do
          is_expected.to contain_file('ca_dir').with(
            'ensure'       => 'directory',
            'recurse'      => true,
            'recurselimit' => 1,
            'mode'         => '0644',
            'path'         => '/etc/pam_pkcs11/cacerts',
            'source'       => ['puppet:///modules/files/pam_pkcs11/ca_dir', 'puppet:///modules/ca_certs/certs'],
            'sourceselect' => sourceselect
          ).that_notifies('Exec[pkcs11_make_hash_link]')
        end

        it do
          is_expected.to contain_exec('pkcs11_make_hash_link').with(
            'refreshonly' => true,
            'cwd'         => '/etc/pam_pkcs11/cacerts',
            'path'        => ['/usr/local/bin', '/usr/local/sbin', '/usr/bin', '/usr/sbin', '/bin', '/sbin']
          )
        end
      end

      context 'when `ca_dir_source` is set' do
        context 'to an Array of valid URIs' do
          let(:params) do
            {
              'ca_dir_source' => [
                'puppet:///modules/files/pam_pkcs11/ca_dir',
                'puppet:///modules/ca_certs/certs',
              ],
            }
          end

          if facts[:osfamily] == 'Debian'
            it_should_behave_like 'a host with an OpenSSL CA hash link directory', 'first'
          elsif facts[:osfamily] == 'RedHat'
            it { is_expected.to raise_error(Puppet::Error) }
          else
            it { is_expected.not_to contain_file('ca_dir') }
            it { is_expected.not_to contain_exec('pkcs11_make_hash_link') }
          end
        end

        context 'to a Boolean' do
          let(:params) { { 'ca_dir_source' => true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to a Number' do
          let(:params) { { 'ca_dir_source' => 1_188_572 } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to a String' do
          let(:params) { { 'ca_dir_source' => 'puppet:///modules/files/ca_certs' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'with supporting parameters set, when `ca_dir_sourceselect` is set' do
        context 'to `all`' do
          let(:params) do
            {
              'ca_dir_sourceselect' => 'all',
              'pkcs11_module'       => { 'ca_dir' => '/etc/pam_pkcs11/cacerts' },
              'ca_dir_source'       => [
                'puppet:///modules/files/pam_pkcs11/ca_dir',
                'puppet:///modules/ca_certs/certs',
              ],
            }
          end

          if facts[:osfamily] == 'RedHat'
            it { is_expected.to raise_error(Puppet::Error) }
          else
            it_should_behave_like 'a host with an OpenSSL CA hash link directory', 'all'
          end
        end

        context 'to `first`' do
          let(:params) do
            {
              'ca_dir_sourceselect' => 'first',
              'pkcs11_module'       => { 'ca_dir' => '/etc/pam_pkcs11/cacerts' },
              'ca_dir_source'       => [
                'puppet:///modules/files/pam_pkcs11/ca_dir',
                'puppet:///modules/ca_certs/certs',
              ],
            }
          end

          if facts[:osfamily] == 'RedHat'
            it { is_expected.to raise_error(Puppet::Error) }
          else
            it_should_behave_like 'a host with an OpenSSL CA hash link directory', 'first'
          end
        end

        context 'to an invalid value' do
          let(:params) { { 'ca_dir_sourceselect' => 'none' } }

          it { is_expected.to raise_error(Puppet::Error, /does not match/) }
        end

        context 'to a non-String' do
          let(:params) { { 'ca_dir_sourceselect' => true } }

          it { is_expected.to raise_error(Puppet::Error, /does not match/) }
        end
      end

      context 'when `manage_pkcs11_eventmgr` =>' do
        context 'true' do
          let(:params) do
            {
              'manage_pkcs11_eventmgr' => true,
            }
          end

          it { is_expected.to contain_class('pam_pkcs11::pkcs11_eventmgr') }
        end

        context 'false' do
          let(:params) do
            {
              'manage_pkcs11_eventmgr' => false,
            }
          end

          it { is_expected.not_to contain_class('pam_pkcs11::pkcs11_eventmgr') }
        end
      end
    end
  end

  context 'on an unsupported operating system' do
    let(:facts) do
      {
        :osfamily        => 'JUNOS',
        :operatingsystem => 'JUNOS',
      }
    end

    context 'without any parameters' do
      it { is_expected.to raise_error(Puppet::Error, /#{facts[:operatingsystem]} not supported/) }
    end
  end
end
# vim:foldmethod=syntax

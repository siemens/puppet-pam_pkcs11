require 'spec_helper'

describe 'pam_pkcs11::pkcs11_eventmgr', type: :class do
  shared_examples_for 'an OS that uses systemd by default' do
    it { is_expected.to contain_file('pkcs11_eventmgr.service') }
  end

  shared_examples_for 'an OS that does not use systemd by default' do
    it { is_expected.not_to contain_file('pkcs11_eventmgr.service') }
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:lib) do
        if facts[:os].fetch('architecture', facts[:architecture]).match?(%r{i[3-6]86})
          'lib'
        else
          'lib64'
        end
      end

      let(:default_module_path) do
        case facts[:os]['family']
        when 'Gentoo'
          '/usr/lib/opensc-pkcs11.so'
        when 'Debian'
          '/usr/lib/opensc-pkcs11.so'
        when 'RedHat', 'Suse'
          "/usr/#{lib}/pkcs11/opensc-pkcs11.so"
        end
      end

      context 'without any parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('pam_pkcs11::pkcs11_eventmgr').that_requires('Class[pam_pkcs11::install]') }

        case facts[:os]['family']
        when 'Gentoo'
          it_behaves_like('an OS that does not use systemd by default')
        when 'Debian'
          case facts[:os]['name']
          when 'Debian'
            case facts[:os]['release']['major']
            when '8'
              it_behaves_like('an OS that uses systemd by default')
            else
              it_behaves_like('an OS that does not use systemd by default')
            end
          when 'Ubuntu'
            case facts[:os]['release']['major']
            when '15.04', '15.10', '16.04'
              it_behaves_like('an OS that uses systemd by default')
            else
              it_behaves_like('an OS that does not use systemd by default')
            end
          end
        when 'RedHat'
          case facts[:os]['name']
          when 'RedHat', 'CentOS', 'Scientific', 'OracleLinux'
            case facts[:os]['release']['major']
            when '7'
              it_behaves_like('an OS that uses systemd by default')
            else
              it_behaves_like('an OS that does not use systemd by default')
            end
          when 'Fedora'
            it_behaves_like('an OS that uses systemd by default')
          end
        when 'Suse'
          case facts[:os]['release']['major']
          when '12', '13', '42'
            it_behaves_like('an OS that uses systemd by default')
          else
            it_behaves_like('an OS that does not use systemd by default')
          end
        end

        it { is_expected.not_to contain_file('pkcs11_eventmgr.desktop') }

        it do
          is_expected.to contain_file('pkcs11_eventmgr.conf').with(
            'ensure'  => 'present',
            'path'    => '/etc/pam_pkcs11/pkcs11_eventmgr.conf',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => <<-END.gsub(%r{^[[:blank:]]{14}}, ''),
              ########################################################################
              #             WARNING: This file is managed by Puppet.                 #
              #               Manual changes will be overwritten.                    #
              ########################################################################
              pkcs11_eventmgr {
                debug = false;
                daemon = true;
                polling_time = 1;
                expire_time = 0;
                pkcs11_module = "#{default_module_path}";

                event card_insert {
                  on_error = "ignore";
                  action = "/bin/true";
                }

                event card_remove {
                  on_error = "ignore";
                  action = "canberra-gtk-play -i device-removed -d 'Smartcard removed'",
                           "dcop kdesktop KScreensaverIface lock",
                           "gnome-screensaver-command -l",
                           "loginctl lock-session",
                           "qdbus org.kde.ScreenSaver /ScreenSaver Lock",
                           "xscreensaver-command -lock";
                }

                event expire_time {
                  on_error = "ignore";
                  action = "/bin/true";
                }
              }
            END
          )
        end
      end # 'without any parameters'

      context 'when `debug` is set' do
        context 'to `true`' do
          let(:params) { { 'debug' => true } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  debug = true;})
          }
        end

        context 'to `false`' do
          let(:params) { { 'debug' => false } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  debug = false;})
          }
        end
      end

      context 'when `daemonize` is set' do
        context 'to `true`' do
          let(:params) { { 'daemonize' => true } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  daemon = true;})
          }
        end

        context 'to `false`' do
          let(:params) { { 'daemonize' => false } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  daemon = false;})
          }
        end
      end

      context 'when `polling_time` is set' do
        context 'to a valid, non-default Number' do
          let(:params) { { 'polling_time' => 120 } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  polling_time = 120;})
          }
        end

        context 'to a valid Number passed as a String' do
          let(:params) { { 'polling_time' => '90' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a non-numeric String' do
          let(:params) { { 'polling_time' => 'one' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is true' do
          let(:params) { { 'polling_time' => true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is false' do
          let(:params) { { 'polling_time' => false } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an an Array' do
          let(:params) { { 'polling_time' => [1] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Hash' do
          let(:params) { { 'polling_time' => { 1 => 1 } } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'when `expire_time` is set' do
        context 'to a valid, non-default Number' do
          let(:params) { { 'expire_time' => 120 } }

          it {
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  expire_time = 120;})
          }
        end

        context 'to a valid Number passed as a String' do
          let(:params) { { 'expire_time' => '90' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a non-numeric String' do
          let(:params) { { 'expire_time' => 'one' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is true' do
          let(:params) { { 'expire_time' => true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is false' do
          let(:params) { { 'expire_time' => false } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an an Array' do
          let(:params) { { 'expire_time' => [1] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Hash' do
          let(:params) { { 'expire_time' => { 1 => 1 } } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'when `pkcs11_module` is set' do
        context 'to `default`' do
          let(:params) { { 'pkcs11_module' => 'default' } }

          it do
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  pkcs11_module = "#{default_module_path}";})
          end
        end

        context 'to a fully qualified path' do
          let(:params) { { 'pkcs11_module' => '/usr/local/lib/pkcs11/opensc-pkcs11.so' } }

          it do
            is_expected.to contain_file('pkcs11_eventmgr.conf')
              .with_content(%r{  pkcs11_module = "/usr/local/lib/pkcs11/opensc-pkcs11\.so";})
          end
        end

        context 'to an invalid String' do
          let(:params) { { 'pkcs11_module' => 'opensc-pkcs11\.so' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is true' do
          let(:params) { { 'pkcs11_module' => true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is false' do
          let(:params) { { 'pkcs11_module' => false } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to a Number' do
          let(:params) { { 'pkcs11_module' => 1 } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an an Array' do
          let(:params) { { 'pkcs11_module' => ['/usr/local/lib/pkcs11/opensc-pkcs11.so'] } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Hash' do
          let(:params) { { 'pkcs11_module' => { 1 => 1 } } }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'when `event_opts` is set' do
        context 'to a valid, non-default Hash' do
          let(:params) do
            {
              'event_opts' => {
                'card_insert' => {
                  'on_error' => 'ignore',
                  'action'   => ['/bin/false'],
                },
                'card_remove' => {
                  'on_error' => 'return',
                  'action'   => ['loginctl lock-session'],
                },
                'expire_time' => {
                  'on_error' => 'quit',
                  'action'   => ['/bin/false'],
                },
              },
            }
          end

          it do
            is_expected.to contain_file('pkcs11_eventmgr.conf').with_content(
              <<-END.gsub(%r{^[[:blank:]]{16}}, ''),
                ########################################################################
                #             WARNING: This file is managed by Puppet.                 #
                #               Manual changes will be overwritten.                    #
                ########################################################################
                pkcs11_eventmgr {
                  debug = false;
                  daemon = true;
                  polling_time = 1;
                  expire_time = 0;
                  pkcs11_module = "#{default_module_path}";

                  event card_insert {
                    on_error = "ignore";
                    action = "/bin/false";
                  }

                  event card_remove {
                    on_error = "return";
                    action = "loginctl lock-session";
                  }

                  event expire_time {
                    on_error = "quit";
                    action = "/bin/false";
                  }
                }
              END
            )
          end
        end

        context 'to an a Boolean that is true' do
          let(:params) { { 'event_opts' => true } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a Boolean that is false' do
          let(:params) { { 'event_opts' => false } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to a Number' do
          let(:params) { { 'event_opts' => 1 } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an a String' do
          let(:params) { { 'event_opts' => 'options!' } }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'to an an Array' do
          let(:params) do
            {
              'event_opts' => [
                ['card_insert', ['on_error ignore'], ['action', ['/bin/true']]],
                ['card_remove', ['on_error ignore'], ['action', ['/bin/true']]],
                ['expire_time', ['on_error ignore'], ['action', ['/bin/true']]],
              ],
            }
          end

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end

      context 'when autostart_method is set' do
        context 'to systemd_service' do
          let(:params) do
            { autostart_method: 'systemd_service' }
          end

          it { is_expected.not_to contain_file('pkcs11_eventmgr.desktop') }
          it do
            is_expected.to contain_file('pkcs11_eventmgr.service').with(
              'ensure'  => 'present',
              'path'    => '/etc/systemd/user/pkcs11_eventmgr.service',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => <<-END.gsub(%r{^[[:blank:]]{16}}, ''),
                [Unit]
                Description=SmartCard PKCS#11 Event Manager
                Documentation=man:pkcs11_eventmgr(1)

                [Service]
                ExecStart=/usr/bin/pkcs11_eventmgr

                [Install]
                WantedBy=default.target
              END
            )
          end
        end

        context 'to xdg_autostart' do
          let(:params) do
            { autostart_method: 'xdg_autostart' }
          end

          it { is_expected.not_to contain_file('pkcs11_eventmgr.service') }
          it do
            is_expected.to contain_file('pkcs11_eventmgr.desktop').with(
              'ensure'  => 'present',
              'path'    => '/etc/xdg/autostart/pkcs11_eventmgr.desktop',
              'owner'   => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'content' => <<-END.gsub(%r{^[[:blank:]]{16}}, ''),
                [Desktop Entry]
                Version=1.0
                Type=Application
                Name=SmartCard PKCS#11 Event Manager
                Exec=/usr/bin/pkcs11_eventmgr
              END
            )
          end
        end

        context 'to none' do
          let(:params) do
            { autostart_method: 'none' }
          end

          it { is_expected.not_to contain_file('pkcs11_eventmgr.service') }
          it { is_expected.not_to contain_file('pkcs11_eventmgr.desktop') }
        end

        context 'to an invalid value' do
          let(:params) do
            { autostart_method: 'invalid string' }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{Evaluation Error}) }
        end

        context 'to an invalid type' do
          let(:params) do
            { autostart_method: false }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{Evaluation Error}) }
        end
      end
    end
  end # on_supported_os
end

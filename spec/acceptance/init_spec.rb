require 'spec_helper_acceptance'

describe 'pam_pkcs11' do
  fixture_path = File.expand_path(File.join(__FILE__, '..', '..', 'fixtures'))

  case fact('osfamily')
  when 'Gentoo'
    package_name = 'sys-auth/pam_pkcs11'
    os_files_path = 'Gentoo'
  when 'Debian'
    package_name = 'libpam-pkcs11'
    os_files_path = 'Debian'
  when 'RedHat', 'Suse'
    package_name = 'pam_pkcs11'
    os_files_path = if fact('architecture') =~ /i[3-6]86/
                      fact('operatingsystemmajrelease') == 5 ? %w(RedHat 32 RedHat-5) : %w(RedHat 32)
                    else
                      fact('operatingsystemmajrelease') == 5 ? %w(RedHat 64 RedHat-5) : %w(RedHat 64)
                    end
  end

  default_pam_pkcs11_conf = File.open(File.join(fixture_path, 'default_files', os_files_path, 'pam_pkcs11.conf')).read
  default_pkcs11_eventmgr_conf = File.open(File.join(fixture_path, 'default_files', os_files_path, 'pkcs11_eventmgr.conf')).read

  context 'with default parameters' do
    it 'should work idempotently with no errors' do
      manifest = <<-END
      class { 'pam_pkcs11': }
      END

      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
    end

    describe package(package_name) do
      it { is_expected.to be_installed }
    end

    describe file('/etc/pam_pkcs11') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '755' }
    end

    describe file('/etc/pam_pkcs11/pam_pkcs11.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '600' }
      its(:content) { should match(default_pam_pkcs11_conf) }
    end

    describe file('/etc/pam_pkcs11/pkcs11_eventmgr.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode '644' }
      its(:content) { should match(default_pkcs11_eventmgr_conf) }
    end
  end

  context 'with `ca_dir_source` set' do
    context 'to a single, valid source' do
      manifest = <<-END
      class { 'pam_pkcs11':
        ca_dir_source => ['puppet:///modules/pam_pkcs11/fixtures/ca_dir'],
      }
      END

      if fact('osfamily') == 'RedHat'
        it 'should fail without making any changes' do
          apply_manifest(manifest, :expect_failures => true, :acceptable_exit_codes => [4])
        end
      else
        it 'should work idempotently with no errors' do
          apply_manifest(manifest, :catch_failures => true)
          apply_manifest(manifest, :catch_changes => true)
        end

        describe file('/etc/pam_pkcs11/cacerts') do
          it { is_expected.to be_directory }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '755' }
        end

        describe file('/etc/pam_pkcs11/cacerts/cacert_class3.der') do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '644' }
          its(:sha256sum) { should eq '4edde9e55ca453b388887caa25d5c5c5bccf2891d73b87495808293d5fac83c8' }
        end

        describe file('/etc/pam_pkcs11/cacerts/cacert_class3.pem') do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '644' }
          its(:sha256sum) { should eq 'f5badaa5da1cc05b110a9492455a2c2790d00c7175dcf3a7bcb5441af71bf84f' }
        end

        describe file('/etc/pam_pkcs11/cacerts/cacert_root.der') do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '644' }
          its(:sha256sum) { should eq 'ff2a65cff1149c7430101e0f65a07ec19183a3b633ef4a6510890dad18316b3a' }
        end

        describe file('/etc/pam_pkcs11/cacerts/cacert_root.pem') do
          it { is_expected.to be_file }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '644' }
          its(:sha256sum) { should eq 'c0e0773a79dceb622ef6410577c19c1e177fb2eb9c623a49340de3c9f1de2560' }
        end

        describe file('/etc/pam_pkcs11/cacerts/590d426f.0') do
          it { is_expected.to be_symlink }
          it { is_expected.to be_linked_to 'cacert_class3.der' }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '777' }
        end

        describe file('/etc/pam_pkcs11/cacerts/590d426f.1') do
          it { is_expected.to be_symlink }
          it { is_expected.to be_linked_to 'cacert_class3.pem' }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '777' }
        end

        describe file('/etc/pam_pkcs11/cacerts/99d0fa06.0') do
          it { is_expected.to be_symlink }
          it { is_expected.to be_linked_to 'cacert_root.der' }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '777' }
        end

        describe file('/etc/pam_pkcs11/cacerts/99d0fa06.1') do
          it { is_expected.to be_symlink }
          it { is_expected.to be_linked_to 'cacert_root.pem' }
          it { is_expected.to be_owned_by 'root' }
          it { is_expected.to be_grouped_into 'root' }
          it { is_expected.to be_mode '777' }
        end
      end
    end

    context 'to an invalid source' do
      manifest = <<-END
      class { 'pam_pkcs11':
        ca_dir_source => ['gopher://localhost/0ca_dir'],
      }
      END

      it 'should fail without making any changes' do
        apply_manifest(manifest, :expect_failures => true, :acceptable_exit_codes => [4])
      end
    end
  end
end

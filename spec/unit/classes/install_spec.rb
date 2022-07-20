require 'spec_helper'

describe 'pam_pkcs11::install', type: :class do
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

      context 'without any parameters' do
        it { is_expected.to contain_package(package_name).with_ensure('present') }
      end
    end
  end
end

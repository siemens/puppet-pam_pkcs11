# == Class pam_pkcs11::params
#
# @summary This class is meant to be called from pam_pkcs11.
#   It sets variables according to platform.
#
class pam_pkcs11::params {
  case $facts['os']['family'] {
    'Gentoo': {
      # Gentoo uses version 0.6.8
      $package_name       = 'sys-auth/pam_pkcs11'
      $opensc_module_path = '/usr/lib/opensc-pkcs11.so'
      $mapper_module_dir  = '/usr/lib/pam_pkcs11'
      $ca_dir             = undef
      $nss_dir            = '/etc/pki/nssdb'
      $cert_policy        = ['signature', 'ca', 'crl_auto', 'ocsp_on']
      $systemd            = false # by default
      $pam_config         = 'none'
    } # end osfamily Gentoo

    'Debian': {
      # Debian 10 uses version 0.6.9
      # Debian 11 uses version 0.6.11
      # Ubuntu 18.04 uses version 0.6.9
      # Ubuntu 20.04 uses version 0.6.11
      # Ubuntu 22.04 uses version 0.6.11
      $package_name = 'libpam-pkcs11'
      $ca_dir       = '/etc/pam_pkcs11/cacerts'
      $nss_dir      = undef
      $cert_policy  = ['signature', 'ca', 'crl_auto']
      $pam_config   = 'pam-auth-update'
      $systemd      = true

      $gcc_arch = $facts['os']['architecture'] ? {
        'amd64' => 'x86_64',
        default  => $facts['os']['architecture']
      }
      $opensc_module_path = "/usr/lib/${gcc_arch}-linux-gnu/pkcs11/opensc-pkcs11.so"

      $mapper_module_dir_old = '/lib/pam_pkcs11'
      $mapper_module_dir_new = "/lib/${gcc_arch}-linux-gnu/pam_pkcs11"

      case $facts['os']['name'] {
        'Debian': {
          $mapper_module_dir = $facts['os']['release']['major'] ? {
            /10/ => $mapper_module_dir_old,
            default  => $mapper_module_dir_new,
          }
        }
        'Ubuntu': {
          $mapper_module_dir = $facts['os']['release']['major'] ? {
            /(18\.04|20\.04)/ => $mapper_module_dir_old,
            default           => $mapper_module_dir_new,
          }
        }
        default: { fail("${facts['os']['name']} not supported") }
      }
    } # end osfamily Debian

    'RedHat', 'Suse': {
      # RHEL 6 uses version 0.6.2
      # RHEL 7 uses version 0.6.2
      $lib = $facts['os']['architecture'] ? {
        /i[3-6]86/ => 'lib',
        default    => 'lib64',
      }

      $package_name       = 'pam_pkcs11'
      $opensc_module_path = "/usr/${lib}/pkcs11/opensc-pkcs11.so"
      $mapper_module_dir  = "/usr/${lib}/pam_pkcs11"
      $ca_dir             = undef
      $nss_dir            = '/etc/pki/nssdb'
      $cert_policy        = ['signature', 'ca', 'crl_auto', 'ocsp_on']
      $pam_config         = 'none'

      if $facts['os']['name'] =~ /RedHat|CentOS|Scientific|OracleLinux/ and $facts['os']['release']['major'] == '6' {
        $systemd = false
      } else {
        $systemd = true
      }
    } # end osfamily RedHat, Suse

    default: { fail("${facts['os']['name']} not supported") }
  }

  $pkcs11_eventmgr_autostart_method = $systemd ? {
    true    => 'systemd_service',
    default => 'none',
  }

  $pkcs11_module = {
    'name'             => 'opensc',
    'module'           => $opensc_module_path,
    'slot_description' => 'none',
    'slot_num'         => undef,
    'ca_dir'           => $ca_dir,
    'crl_dir'          => '/etc/pam_pkcs11/crls',
    'nss_dir'          => $nss_dir,
    'support_threads'  => true,
    'cert_policy'      => join($cert_policy, ','),
    'token_type'       => 'smart card',
  }

  $mapper_options = {
    'digest' => {
      'debug'     => false,
      'module'    => 'internal',
      'algorithm' => 'sha1',
      'mapfile'   => 'file:///etc/pam_pkcs11/digest_mapping',
    },
    'ldap' => {
      'debug'          => false,
      'module'         => "${mapper_module_dir}/ldap_mapper.so",
      'ldaphost'       => '',
      'ldapport'       => '',
      'URI'            => 'ldaps://127.0.0.1',
      'scope'          => 2,
      'binddn'         => '',
      'passwd'         => '',
      'base'           => '',
      'attribute'      => 'userCertificate',
      'filter'         => '(&(objectClass=posixAccount)(uid=%s))',
      'ssl'            => 'on',
      'tls_cacertfile' => '/etc/ssl/cacert.pem',
      'tls_cacertdir'  => undef,
      'tls_checkpeer'  => undef,
      'tls_ciphers'    => undef,
      'tls_cert'       => undef,
      'tls_key'        => undef,
      'tls_randfile'   => '/dev/urandom',
    },
    'generic' => {
      'debug'        => false,
      'module'       => 'internal',
      'mapfile'      => 'file:///etc/pam_pkcs11/generic_mapping',
      'ignorecase'   => false,
      'cert_item'    => 'cn',
      'use_getpwent' => false,
    },
    'subject' => {
      'debug'      => false,
      'module'     => 'internal',
      'mapfile'    => 'file:///etc/pam_pkcs11/subject_mapping',
      'ignorecase' => false,
    },
    'openssh' => {
      'debug'  => false,
      'module' => "${mapper_module_dir}/openssh_mapper.so",
    },
    'opensc' => {
      'debug'  => false,
      'module' => "${mapper_module_dir}/opensc_mapper.so",
    },
    'pwent' => {
      'debug'      => false,
      'module'     => 'internal',
      'ignorecase' => false,
    },
    'null' => {
      'debug'         => false,
      'module'        => 'internal',
      'default_match' => false,
      'default_user'  => 'nobody',
    },
    'cn' => {
      'debug'      => false,
      'module'     => 'internal',
      'mapfile'    => 'none',
      'ignorecase' => true,
    },
    'mail' => {
      'debug'        => false,
      'module'       => 'internal',
      'mapfile'      => 'file:///etc/pam_pkcs11/mail_mapping',
      'ignorecase'   => true,
      'ignoredomain' => false,
    },
    'ms' => {
      'debug'        => false,
      'module'       => 'internal',
      'ignorecase'   => false,
      'ignoredomain' => false,
      'domainname'   => 'example.com',
    },
    'krb' => {
      'debug'      => false,
      'module'     => 'internal',
      'ignorecase' => false,
      'mapfile'    => 'none',
    },
    'uid' => {
      'debug'      => false,
      'module'     => 'internal',
      'ignorecase' => false,
      'mapfile'    => 'none',
    },
  }

  $pkcs11_event_opts = {
    'card_insert' => {
      'on_error' => 'ignore',
      'action'   => ['/bin/true'],
    },
    'card_remove' => {
      'on_error' => 'ignore',
      'action'   => ['/bin/true'],
    },
    'expire_time' => {
      'on_error' => 'ignore',
      'action'   => ['/bin/true'],
    },
  }

  $pkcs11_event_opts_lock_screen_on_card_remove = {
    'card_remove' => {
      'on_error' => 'ignore',
      'action'   => [
        "canberra-gtk-play -i device-removed -d 'Smartcard removed'",
        'xscreensaver-command -lock',
        'gnome-screensaver-command -l',
        'dcop kdesktop KScreensaverIface lock',
        'qdbus org.kde.ScreenSaver /ScreenSaver Lock',
        'loginctl lock-session',
      ],
    },
  }
}

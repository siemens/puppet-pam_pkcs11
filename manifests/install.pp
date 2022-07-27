# == Class pam_pkcs11::install
#
# @summary This class is called from pam_pkcs11 for install.
#
class pam_pkcs11::install {
  include 'pam_pkcs11'

  package { $pam_pkcs11::package_name:
    ensure  => present,
  }
}

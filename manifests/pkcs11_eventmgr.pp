# == Class pam_pkcs11::pkcs11_eventmgr
#
# @summary This class is called from pam_pkcs11 to configure `pkcs11_eventmgr(1)`.
#
# @param debug
#   Boolean
#
#   Default: false
#
# @param daemonize
#   Boolean
#
#   Default: true
#
# @param polling_time
#   Integer
#
#   Default: 1
#
# @param expire_time
#   Integer
#
#   Default: 0
#
# @param pkcs11_module
#   String
#
#   Default: 'default'
#
# @param event_opts
#   Hash
#
#   Default: {}
#
# @param event_opts_base
#   Hash
#
#   Default: $pam_pkcs11::params::pkcs11_event_opts
#
# @param autostart_method
#   String
#
#   Default: $pam_pkcs11::params::pkcs11_eventmgr_autostart_method,
#
class pam_pkcs11::pkcs11_eventmgr (
  Boolean                 $debug            = false,
  Boolean                 $daemonize        = true,
  Integer[0]              $polling_time     = 1,
  Integer[0]              $expire_time      = 0,
  Variant[Enum['default'],
  Stdlib::AbsolutePath]   $pkcs11_module    = 'default',
  Pam_pkcs11::EventCfgOpt $event_opts       = {},
  Pam_pkcs11::EventCfg    $event_opts_base  = $pam_pkcs11::params::pkcs11_event_opts,
  Enum['systemd_service',
    'xdg_autostart',
  'none']                 $autostart_method = $pam_pkcs11::params::pkcs11_eventmgr_autostart_method,
) inherits pam_pkcs11::params {
  require 'pam_pkcs11::install'
  include 'pam_pkcs11'

  if $pkcs11_module == 'default' {
    $pkcs11_module_file = $pam_pkcs11::merged_pkcs11_module['module']
  } else {
    $pkcs11_module_file = $pkcs11_module
  }

  $merged_event_opts = merge($event_opts_base, $event_opts)

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { 'pkcs11_eventmgr.conf':
    path    => '/etc/pam_pkcs11/pkcs11_eventmgr.conf',
    content => template('pam_pkcs11/pkcs11_eventmgr.conf.erb'),
  }

  if $autostart_method == 'systemd_service' {
    file { 'pkcs11_eventmgr.service':
      path    => '/etc/systemd/user/pkcs11_eventmgr.service',
      content => template('pam_pkcs11/pkcs11_eventmgr.service.erb'),
    }
  } elsif $autostart_method == 'xdg_autostart' {
    file { 'pkcs11_eventmgr.desktop':
      path    => '/etc/xdg/autostart/pkcs11_eventmgr.desktop',
      content => template('pam_pkcs11/pkcs11_eventmgr.desktop.erb'),
    }
  }
}

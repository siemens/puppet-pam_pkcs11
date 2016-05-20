# == Class pam_pkcs11::pkcs11_eventmgr
#
# This class is called from pam_pkcs11 to configure `pkcs11_eventmgr(1)`.
#
class pam_pkcs11::pkcs11_eventmgr (
  $debug            = false,
  $daemonize        = true,
  $polling_time     = 1,
  $expire_time      = 0,
  $pkcs11_module    = 'default',
  $event_opts       = {},
  $autostart_method = $::pam_pkcs11::params::pkcs11_eventmgr_autostart_method,
) inherits pam_pkcs11::params {

  require '::pam_pkcs11::install'
  include '::pam_pkcs11'

  if $pkcs11_module == 'default' {
    $pkcs11_module_file = $::pam_pkcs11::merged_pkcs11_module['module']
  } else {
    validate_absolute_path($pkcs11_module)
    if is_array($pkcs11_module) { fail('The paremeter `pkcs11_module` must be a String.  It is an Array.') }
    $pkcs11_module_file = $pkcs11_module
  }

  validate_bool($debug)
  validate_bool($daemonize)
  validate_integer($polling_time, undef, 0)
  if is_array($polling_time) { fail('The paremeter `polling_time` must be an Integer.  It is an Array.') }
  validate_integer($expire_time, undef, 0)
  if is_array($expire_time) { fail('The paremeter `expire_time` must be an Integer.  It is an Array.') }
  validate_string($autostart_method)
  validate_re($autostart_method, '^(?:systemd_service|xdg_autostart|none)$')
  validate_hash($event_opts)

  $merged_event_opts = merge($::pam_pkcs11::params::pkcs11_event_opts, $event_opts)

  validate_re($merged_event_opts['card_insert']['on_error'], '^(?:ignore|return|quit)$')
  validate_re($merged_event_opts['card_remove']['on_error'], '^(?:ignore|return|quit)$')
  validate_re($merged_event_opts['expire_time']['on_error'], '^(?:ignore|return|quit)$')

  # TODO: Use `validate_cmd()` on individual action strings once support for
  #       Puppet 3.x and lower is dropped (requires iteration).
  validate_array($merged_event_opts['card_insert']['action'])
  validate_array($merged_event_opts['card_remove']['action'])
  validate_array($merged_event_opts['expire_time']['action'])

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

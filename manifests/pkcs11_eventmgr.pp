# == Class pam_pkcs11::pkcs11_eventmgr
#
# @summary This class is called from pam_pkcs11 to configure `pkcs11_eventmgr(1)`.
#
# @param debug
#   Boolean
#
#   Whether or not to enable debugging for the `pkcs11_eventmgr` module.
#
#   Default: false
#
# @param daemonize
#   Boolean
#
#   Whether or not to run the service in the background.
#
#   Default: true
#
# @param polling_time
#   Integer
#
#   Time in seconds between two consecutive status polls.
#
#   Default: 1
#
# @param expire_time
#   Integer
#
#   Time in seconds between card removal and triggering of the expire event.
#
#   Default: 0
#
# @param pkcs11_module
#   String
#
#   Path to the pkcs11 module.
#
#   Default: 'default'
#
# @param event_opts
#   Hash
#
#   Event configuration for the `card_insert`, `card_remove` and `expire_time`
#   event.  This will overwrite the default configuration from the
#   `event_opts_base` and `event_opts_screen_lock` parameter.
#
#   Default: {}
#
# @param event_opts_base
#   Hash
#
#   The default event configuration for the `card_insert`, `card_remove` and
#   `expire_time` event.  This is used as a base default configuration.
#
#   Default: $pam_pkcs11::params::pkcs11_event_opts
#
# @param event_opts_screen_lock
#   Hash
#
#   The event configuration that is applied whether the
#   `lock_screen_on_card_remove` parameter is set to true.  This will overwrite
#   the `event_opts_base` configuration and will be overwritten by the
#   `event_opts` configuration.
#
#   Default: $pam_pkcs11::params::pkcs11_event_opts_lock_screen_on_card_remove
#
# @param autostart_method
#   String
#
#   The method how the service are started on boot.
#
#   Default: $pam_pkcs11::params::pkcs11_eventmgr_autostart_method,
#
# @param lock_screen_on_card_removal
#   Boolean
#
#   Whether or not to configure screen lock when the card is removed.  If set
#   to true, the event configuration from `event_opts_screen_lock` will be
#   applied.
#
#   Default: true
class pam_pkcs11::pkcs11_eventmgr (
  Boolean                 $debug                  = false,
  Boolean                 $daemonize              = true,
  Integer[0]              $polling_time           = 1,
  Integer[0]              $expire_time            = 0,
  Variant[Enum['default'],
  Stdlib::AbsolutePath]   $pkcs11_module          = 'default',
  Pam_pkcs11::EventCfgOpt $event_opts             = {},
  Pam_pkcs11::EventCfg    $event_opts_base        = $pam_pkcs11::params::pkcs11_event_opts,
  Pam_pkcs11::EventCfgOpt $event_opts_screen_lock = $pam_pkcs11::params::pkcs11_event_opts_lock_screen_on_card_remove,
  Enum['systemd_service',
    'xdg_autostart',
  'none']                 $autostart_method = $pam_pkcs11::params::pkcs11_eventmgr_autostart_method,
  Boolean                 $lock_screen_on_card_removal = true,
) inherits pam_pkcs11::params {
  require 'pam_pkcs11::install'
  include 'pam_pkcs11'

  if $pkcs11_module == 'default' {
    $pkcs11_module_file = $pam_pkcs11::merged_pkcs11_module['module']
  } else {
    $pkcs11_module_file = $pkcs11_module
  }

  if $lock_screen_on_card_removal {
    $merged_event_opts = $event_opts_base + $event_opts_screen_lock + $event_opts
  } else {
    $merged_event_opts = $event_opts_base + $event_opts
  }

  File {
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/etc/pam_pkcs11/pkcs11_eventmgr.conf':
    content => template('pam_pkcs11/pkcs11_eventmgr.conf.erb'),
  }

  if $autostart_method == 'systemd_service' {
    file { '/etc/systemd/user/pkcs11_eventmgr.service':
      content => template('pam_pkcs11/pkcs11_eventmgr.service.erb'),
    }
  } elsif $autostart_method == 'xdg_autostart' {
    file { '/etc/xdg/autostart/pkcs11_eventmgr.desktop':
      content => template('pam_pkcs11/pkcs11_eventmgr.desktop.erb'),
    }
  }
}

# `pam_pkcs11`

This project is a Puppet module to manage *pam_pkcs11*, a PAM module developed
as part of the [OpenSC project] for advanced authentication with smart cards
and other PKCS #11 cryptographic modules.

[OpenSC project]: https://github.com/OpenSC/OpenSC/wiki

## Table of Contents

1. [Setup - The basics of getting started with pam_pkcs11](#setup)
  * [What pam_pkcs11 affects](#what-pam_pkcs11-affects)
  * [Setup requirements](#setup-requirements)
  * [Beginning with pam_pkcs11](#beginning-with-pam_pkcs11)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](CONTRIBUTING.md)

## Setup

### What `pam_pkcs11` affects

In addition to installing and configuring the core `pam_pkcs11(8)` PAM module,
this Puppet module assists in the creation of mapper files to associate users
with their certificates. It can also manage some aspects of the session lock
policy through the configuration of the `pkcs11_eventmgr(8)` daemon, part of the
*pam_pkcs11* package.

### Setup Requirements

#### PAM stack configuration

Currently, PAM is only configured on the supported Debian-based platforms
(Debian and Ubuntu) using `pam-auth-update`. On other platforms, configure PAM
to use `pam_pkcs11(8)` via other means, be that another Puppet module, a Puppet
profile, or something else. In most cases just the following line in the PAM
configuration is all that is required:

```text
auth sufficient pam_pkcs11.so
```

Please refer to the [section on PAM configuration][1] from the [official
pam_pkcs11 documentation][2] for further details.

[1]: https://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html#pamconfig
[2]: https://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html

### Beginning with `pam_pkcs11`

By default this module will install *pam_pkcs11* and configure it to use the
OpenSC PKCS#11 module, checking user certificates against a certificate
authority (CA) trust store, and the certificates contained on a PKCS#11 token
to users based on the SHA-1 certificate fingerprints (via the *[digest
mapper]*). None of this is useful on its own, so we also provide parameters to
install user mapping data and CA certificates.

To associate the certificates contained on a smart card or other PKCS#11 token,
use the `digest_mappings` parameter like so:

```puppet
class { 'pam_pkcs11':
  digest_mappings => {
    'alice' => '79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF',
    'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
  },
}
```

Handling CA certificates is more difficult because depending on the
cryptographic backend they are stored differently. The most common back-end
options are NSS and OpenSSL. Unfortunately, this module does not currently
support NSS database storage. See the [Limitations section](#limitations)
below for more details.

For Debian-based systems, the parameters `ca_dir_source` and
`ca_dir_sourceselect` provide a way to specify CA file sources for the OpenSSL
hash dir back-end. The parameters are simply passed on to a puppet file
resource, as `source` and `sourceselect` with the caveat that `ca_source_dir`
has to be an array of strings. See the puppet documentation about the
[file](https://puppet.com/docs/puppet/7/types/file.html) resource for more
information.

Extending the example from before, here all the CA certificates are stored in the
`ca_dir` sub-directory of a "*files*" module are installed on the target host:

```puppet
class { 'pam_pkcs11':
  digest_mappings => {
    'alice' => '79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF',
    'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
  },
  ca_dir_source => ['puppet:///modules/files/ca_dir'],
}
```

With this configuration, Alice and Bob should be able to authenticate, provided
the certificates on their smart cards were issued by a trusted CA and have not
been revoked.

[digest mapper]: http://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html#idp5267200

## Usage

The base `pam_pkcs11` class is the *primary point of entry* for this module.
This class should be declared with its parameters defined as appropriate to the
deployment environment.

The sub-class `pam_pkcs11::pkcs11_eventmgr` provides a supplementary interface
to configure the `pkcs11_eventmgr(1)` session lock daemon. It will be enabled
via the `pam_pkcs11::manage_pkcs11_eventmgr` parameter.

## Reference

### Classes

#### Public Classes

* [`pam_pkcs11`](#pam_pkcs11-class): The primary point of entry to this module.
* [`pam_pkcs11::pkcs11_eventmgr`](#pam_pkcs11pkcs11_eventmgr-class):
  Manages `pkcs11_eventmgr(1)`, the session lock helper daemon.

#### Private Classes

* `pam_pkcs11::install`: Manages installation of the *pam_pkcs11* package.
* `pam_pkcs11::config`: Manages configuration of the various configuration files.
* `pam_pkcs11::params`: Contains the default configuration parameters.

### Parameters

#### `pam_pkcs11` class

##### `pam_pkcs11::package_name`

The package name that provides the *pam_pkcs11* software.

##### `pam_pkcs11::debug`

Affects the `debug` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::nullok`

Affects the `nullok` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::use_first_pass`

Affects the `use_first_pass` configuration option of the resulting
[`pam_pkcs11` configuration file][3].

##### `pam_pkcs11::try_first_pass`

Affects the `try_first_pass` configuration option of the resulting
[`pam_pkcs11` configuration file][3].

##### `pam_pkcs11::use_authtok`

Affects the `use_authtok` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::card_only`

Affects the `card_only` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::wait_for_card`

Affects the `wait_for_card` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::pkcs11_module`

Affects the `pkcs11_module` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

This parameter overwrites the base settings from
`pam_pkcs11::pkcs11_module_base`.

##### `pam_pkcs11::pkcs11_module_base`

Affects the `pkcs11_module` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

This parameter provides the distribution-dependent base settings. Per default
values from the `pam_pkcs11::params` class are used. If some customization on
top of those base settings is necessary, use the `pam_pkcs11::pkcs11_module`
parameter, otherwise use this parameter to define new base settings.

##### `pam_pkcs11::use_mappers`

Affects the `use_mappers` configuration option of the resulting [`pam_pkcs11`
configuration file][3].

##### `pam_pkcs11::mapper_options`

Affects the `mapper *` configuration entries of the resulting [`pam_pkcs11`
configuration file][3].

This parameter overwrites the base settings from
`pam_pkcs11::mapper_options_base`.

##### `pam_pkcs11::mapper_options_base`

Affects the `mapper *` configuration entries of the resulting [`pam_pkcs11`
configuration file][3].

This parameter provides the distribution-dependent base settings. Per default
values from the `pam_pkcs11::params` class are used. If some customization on
top of those base settings is necessary, use the `pam_pkcs11::mapper_options`
parameter, otherwise use this parameter to define new base settings.

##### `pam_pkcs11::digest_mappings`

Affects the content of [`digest_mappings` configuration file][4].

It contains a hash that maps user logins to certificate fingerprints. The keys
are the user logins and the values are the certificate fingerprints.

##### `pam_pkcs11::subject_mappings`

Affects the content of [`subject_mappings` configuration file][5].

It contains a hash that maps user logins to certificate subjects. The keys are
the user logins and the values are the certificate subjects.

##### `pam_pkcs11::uid_mappings`

Affects the content of `uid_mappings` configuration file.

It contains a hash that maps user logins to certificate unique identifiers
(UIDs). The keys are the user logins and the values are the certificate UIDs.

##### `pam_pkcs11::ca_dir_source`

An array of file source URIs, which should be populated into the trusted CA
certificate pool of the target host.

##### `pam_pkcs11::ca_dir_sourceselect`

Can either be `first` or `all` and defines the `sourceselect` parameter of the
file resource that copies the CA certificates to the target host.

##### `pam_pkcs11::manage_pkcs11_eventmgr`

Defines if the `pkcs11_eventmgr` should be configured and managed or not.

##### `pam_pkcs11::pam_config`

Defines which PAM configuration framework is used. Currently, only
`pam-auth-update` is supported. Set this to `none` to handle PAM configuration
elsewhere or manually.

#### `pam_pkcs11::pkcs11_eventmgr` class

##### `pam_pkcs11::pkcs11_eventmgr::debug`

Affects the `debug` configuration option of the resulting [`pkcs11_eventmgr`
configuration file][6].

##### `pam_pkcs11::pkcs11_eventmgr::daemonize`

Affects the `daemonize` configuration option of the resulting
[`pkcs11_eventmgr` configuration file][6].

##### `pam_pkcs11::pkcs11_eventmgr::polling_time`

Affects the `polling_time` configuration option of the resulting
[`pkcs11_eventmgr` configuration file][6].

##### `pam_pkcs11::pkcs11_eventmgr::expire_time`

Affects the `expire_time` configuration option of the resulting
[`pkcs11_eventmgr` configuration file][6].

##### `pam_pkcs11::pkcs11_eventmgr::pkcs11_module`

Affects the `pkcs11_module` configuration option of the resulting
[`pkcs11_eventmgr` configuration file][6].

##### `pam_pkcs11::pkcs11_eventmgr::event_opts`

Affects the `event *` configuration entries of the resulting [`pkcs11_eventmgr`
configuration file][6].

This parameter overwrites the base settings from
`pam_pkcs11::pkcs11_eventmgr::event_opts_base` (and
`pam_pkcs11::pkcs11_eventmgr::event_opts_screen_lock` if
`pam_pkcs11::pkcs11_eventmgr::lock_screen_on_card_removal` is enabled).

##### `pam_pkcs11::pkcs11_eventmgr::event_opts_base`

Affects the `event *` configuration entries of the resulting [`pkcs11_eventmgr`
configuration file][6].

This parameter provides the distribution-dependent base settings. Per default
values from the `pam_pkcs11::params` class are used. If some customization on
top of those base settings is necessary, use the
`pam_pkcs11::pkcs11_eventmgr::event_opts` parameter, otherwise use this
parameter to define new base settings.

##### `pam_pkcs11::pkcs11_eventmgr::event_opts_screen_lock`

Affects the `event *` configuration entries of the resulting [`pkcs11_eventmgr`
configuration file][6].

When `pam_pkcs11::pkcs11_eventmgr::lock_screen_on_card_removal` is enabled,
these settings will be merged into the resulting `event *` configuration. It
overwrites settings from `pam_pkcs11::pkcs11_eventmgr::event_opts_base`, but
can still be overwritten by any settings in
`pam_pkcs11::pkcs11_eventmgr::event_opts`.

##### `pam_pkcs11::pkcs11_eventmgr::autostart_method`

This defines how the `pkcs11_eventmgr` service is started. Currently only
`systemd_service` and `xdg_autostart` is supported. Choose `none` in case the
autostart of the daemon is configured elsewhere.

##### `pam_pkcs11::pkcs11_eventmgr::lock_screen_on_card_removal`

This option defines if the
`pam_pkcs11::pkcs11_eventmgr::event_opts_screen_lock` should be merged into the
`event *` configuration or not.

## Limitations

Please see the disclaimer of liability in the [`LICENSE`](LICENSE) file.

### Operating System Compatibility

Although no guarantees can be made, this module is designed to work on the
following operating systems:

* Red Hat Enterprise Linux 6 and 7
* CentOS 6 and 7
* Scientific Linux 6 and 7
* Oracle Linux 6 and 7
* Ubuntu 18.04 and 20.04
* Debian 9, 10 and 11
* SUSE Linux Enterprise Server 12 and 15

### Puppet Stack Compatibility

This module is tested with the following software. For complete details see
the GitHub actions configuration.

* Puppet
  * 6.27
  * 7.17
* Ruby
  * 2.5
  * 2.6
  * 2.7

### CA certificate storage

This module cannot currently manage CA certificates stored in an NSS database,
so users of that storage back-end must install them via other means. One option
is Joshua Hoblitt's [nsstools module]; however, due to limitations in `certutil`
it cannot currently handle multiple certificates with the same subject, a
scenario commonly used for large-scale intermediate CAs.

On systems using non-NSS CA storage (OpenSSL hash dirs), the module provides
the `ca_dir_source` and `ca_dir_sourceselect` parameters; however, they are not
supported on the `RedHat` OS family due to a missing script.

[nsstools module]: https://github.com/jhoblitt/puppet-nsstools

### Known bugs

* [OpenSC/pam_pkcs11#19](https://github.com/OpenSC/pam_pkcs11/issues/19):

    If there are multiple trusted CAs with the same subject, online CRL checks
    may fail during CRL signature verification. The workaround is to use
    pre-downloaded CRLS and `crl_offline` in the `cert_policy` to skip the
    signature verification of the CRLs; it is still a good idea to check the
    signatures upon download.

### TODO

[3]: https://github.com/OpenSC/pam_pkcs11/blob/pam_pkcs11-0.6.12/etc/pam_pkcs11.conf.example.in
[4]: https://github.com/OpenSC/pam_pkcs11/blob/pam_pkcs11-0.6.12/etc/digest_mapping.example
[5]: https://github.com/OpenSC/pam_pkcs11/blob/pam_pkcs11-0.6.12/etc/subject_mapping.example
[6]: https://github.com/OpenSC/pam_pkcs11/blob/pam_pkcs11-0.6.12/etc/pkcs11_eventmgr.conf.example

# pam_pkcs11

[![Build Status](https://travis-ci.org/lamawithonel/puppet-pam_pkcs11.svg?branch=master)](https://travis-ci.org/lamawithonel/puppet-pam_pkcs11)

This is a Puppet module to manage *pam_pkcs11*, a PAM module developed as part
of the [OpenSC project] for advanced authentication with smart cards and other
PKCS #11 cryptographic modules.

[OpenSC project]: https://github.com/OpenSC/OpenSC/wiki

### END-OF-LIFE NOTICE

_pam_pkcs11_ is unmaintained, as is this repository.  The repository is closed
for bug reports and pull requests.  Please feel free to fork it in accordance
with the licence terms.

#### Table of Contents

1. [Setup - The basics of getting started with pam_pkcs11](#setup)
    * [What pam_pkcs11 affects](#what-pam_pkcs11-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pam_pkcs11](#beginning-with-pam_pkcs11)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Setup

### What pam_pkcs11 affects

In addition to installing and configuring the core `pam_pkcs11(8)` PAM module,
this Puppet module assists in the creation of mapper files to associate users
with their certificates.  It can also manage some asspects of session lock
policy through configuraiton of the `pkcs11_eventmgr(8)` daemon, part of the
*pam_pkcs11* package.

### Setup Requirements

#### PAM stack configuration

**This module does not configure PAM itself.**  PAM must be configured to use
`pam_pkcs11(8)` via other means, be that another Puppet module, a Puppet
profile, or something else.  However PAM configuration is applied, the following
line is generally all that is required.

    auth sufficient pam_pkcs11.so

Please refer to the [section on PAM configuration] from the [official pam_pkcs11
documentation] for further details.

[section on PAM configuration]: http://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html#pamconfig  "PAM PKCS #11 Manual: PAM Configuration"
[official pam_pkcs11 documentation]: http://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html "PAM PKCS #11 Manual"

#### Gentoo USE flags

Because the OpenSSL back-end cannot perform OCSP checks, this module defaults to
the NSS back-end for Gentoo; however, the default Gentoo profiles do not set the
`nss` USE flag.  If CA checks are to be performed, this flag must be enabled for
`app-auth/pam_pkcs11`.  Alternatively, the `nss_dir` option can be unset and the
`ca_dir` set in the `pkcs11_module` parameter hash.

### Beginning with pam_pkcs11

By default this module will install *pam_pkcs11* and configure it to use the
OpenSC PKCS#11 module, checking user certificates against a certificate
authority (CA) trust store, and the certificates contained on a PKCS#11 token
to users based on the SHA-1 certificate fingerprints (via the *[digest
mapper]*).  None of this is usefull on its own, so we also provide parameters to
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

CA certificates are little more difficult because they are stored differently
based which cryptographic back-end is used.  The back-end options are NSS and
OpenSSL.  On most supported operating systems the default is NSS.
Unfortunately, this modules does not currently suppot NSS database storage.  See
the [Limitations section](#limitations) below for more details.

For Gentoo and Debian-based systems, the parameters `ca_dir_source` and
`ca_dir_sourceselect` provide a way to specify CA file sources for the OpenSSL
hash dir back-end.  The parameters simply pass to a file resource, so most
values that are valid for `source` and `sourceselect` are valid for the
parameters.  The only caveat is that `ca_dir_source` MUST be an Array.

Adding to the above example, here all the CA certificates are stored in the
`ca_dir` sub-directory of a "*files*" module:

```puppet
class { 'pam_pkcs11':
  digest_mappings => {
    'alice' => '79:E7:27:38:59:24:C6:AD:92:E5:AA:FA:20:0F:D6:9A:D5:47:87:DF',
    'bob'   => 'DD:75:AD:96:0E:CD:BD:25:E7:27:02:8B:34:3D:E4:08:FA:44:A8:31',
  },
  ca_dir_source => ['puppet:///modules/files/ca_dir'],
}
```

With this configuration Alice and Bob should be able to authenticate, provided
the certificates on their smart cards were issued by a trusted CA and have not
been revoked.

[digest mapper]: http://opensc.github.io/pam_pkcs11/doc/pam_pkcs11.html#idp5267200

## Usage

The base `pam_pkcs11` class is the *primary point of entry* for this module.
This class should be declared with its parameters modified as appropriate to the
deployment environment.

The sub-class `pam_pkcs11::pkcs11_eventmgr` provides a supllementary interface to
configure the `pkcs11_eventmgr(1)` session lock daemon.

### Using the LDAP mapper

TODO

### Using pkcs11_eventmgr

TODO

## Reference

### Classes

#### Public Classes

 * [`::pam_pkcs11`](#::pam_pkcs11): The primary point of entry to this module.
 * [`::pam_pkcs11::pkcs11_eventmgr`](#::pam_pkcs11::pkcs11_eventmgr): Manages `pkcs11_eventmgr(1)`, the session lock helper daemon.

#### Private Classes

 * [`::pam_pkcs11::install`]: Manages installation of the the *pam_pkcs11* package.
 * [`::pam_pkcs11::config`]: Manages configuration of the various files.
 * [`::pam_pkcs11::params`]: Contains the default data.

### Parameters

#### ::pam_pkcs11

TODO

##### package_name
##### debug
##### nullok
##### use_first_pass
##### try_first_pass
##### use_authtok
##### card_only
##### wait_for_card
##### pkcs11_module
##### use_mappers
##### mapper_options
##### digest_mappings
##### ca_dir_source
##### ca_dir_sourceselect
##### manage_pkcs11_eventmgr

#### ::pam_pkcs11::pkcs11_eventmgr

TODO

##### debug
##### daemonize
##### polling_time
##### expire_time
##### pkcs11_module
##### event_opts

## Limitations

Please see the disclaimer of liability in the `LICENSE` file.

### Operating System Compatibility

Although no guarantees can be made, this module is designed to work on the
following operating systems:

 * Gentoo Linux
 * Red Hat Enterprise Linux 5, 6, and 7
 * CentOS 5, 6, and 7
 * Scientific Linux 5, 6, and 7
 * Oracle Linux 5, 6, and 7
 * Ubuntu 12.04, 14.04, and 16.04
 * Debian 6, 7, and 8
 * SUSE Linux Enterprise Desktop 11 and 12
 * SUSE Linux Enterprise Server 11 and 12
 * OpenSUSE 13 and 42

### Puppet Stack Compatibility

This module is tested with the following software.  For complete details see the
`.travis.yml` file.

 * Puppet
    - 3.8
	- 4.2
	- 4.3
 * Facter
    - 2.4
 * Ruby
    - 1.8.7
	- 1.9.3
	- 2.0.0
    - 2.1
	- 2.2
	- 2.3 (experimental)

### CA certificate storage

This module cannot currently manage CA certificates stored in an NSS database,
so users of that storage back-end must install them via other means.  One option
is Joshua Hoblitt's [nsstools module], however due to limitations in `certutil`
it cannot currently handle multiple certificates with the same subject, a
scenario commonly used for large-scale intermediate CAs.

On systems using non-NSS CA storage (OpenSSL hash dirs), the module provides
the `ca_dir_source` and `ca_dir_sourceselect` parameters; however, they are not
supported on the `RedHat` OS family due to a missing script.

[nsstools module]: https://github.com/jhoblitt/puppet-nsstools

### Kown bugs

 * OpenSC/pam_pkcs11#19
    If there are multiple trusted CAs with the same subject, online CRL checks
	may fail during CRL signature verification.  The workaround is to use
	pre-downloaded CRLS and `crl_offline` in the `cert_policy` to skip the
	signature verification of the CRLs; it is still a good idea to check the
	signatures upon download.

## Development

### TODO

Eventually support for Puppet 3.x and older should be dropped so the module can
take advantage of all the nice Puppet 4 parser features.  Namely, the type
declarations would help clean up the input validation, and iterations would
allow deep validation of the hashes and arrays.

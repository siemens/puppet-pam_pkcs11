# Class: pam_pkcs11
# ===========================
#
# @summary Manages the pam_pkcs11 Linux-PAM module and associated tools.
#
# Parameters
# ----------
#
# @param package_name
#   String
#
#   The name of the package to install.
#
#   Default: (platform dependent)
#
# @param debug
#   Boolean
#
#   Whether or not to enable debugging for the `pam_pkcs11` PAM module.
#
#   Default: false
#
# @param nullok
#   Boolean
#
# @param use_first_pass
#   Boolean
#
# @param try_first_pass
#   Boolean
#
# @param use_authtok
#   Boolean
#
# @param card_only
#   Boolean
#
# @param wait_for_card
#   Boolean
#
# @param pkcs11_module
#   Hash
#
#   A hash containing configuration for the selected PKCS #11 module.  The
#   key/value pairs in this hash are map directly to the `pam_pkcs11` hash in
#   `pam_pkcs11.conf(5)`.  The provided hash is merged with the defaults from
#   `params.pp`.
#
#   Default: (see params.pp)
#
# @param use_mappers
#   Array
#
#   An array of mappers to use.
#
#   Default: ['digest']
#
# @param mapper_options
#   Hash
#
#   A nested hash with options for each mapper in use.  The first-level key name
#   specifies the mapper.  Key/value pairs from each sub-hash map directly to
#   the `mapper` options in `pam_pkcs11.conf(5)`.  The provided hash is merged
#   with the defaults from `params.pp`.
#
#   Default: (see params.pp)
#
# @param digest_mappings
#   Hash
#
#   A hash of user/fingerprint pairs for use with the `digest` mapper.  Each key
#   name represents a UID, its associated value represents the fingerprint of
#   the user's certificate.
#
#   Default: {}
#
# @param subject_mappings
#   Hash
#
#   Default: {}
#
# @param uid_mappings
#   Hash
#
#   Default: {}
#
# @param ca_dir_source
#   Array
#
#   An array of source URIs for the CA directory.  URIs must be `puppet://` URIs
#   pointing to directory.  The CA directory is managed recursively, so the
#   standard File resource rules apply: if only one URI is specified, then it
#   will be used exclusively as a the source and all its contents will be copied
#   to the target directory.  If more than one URI is specified and
#   `ca_dir_sourceselect` is *not* set to `all` then the array functions as a
#   lookup path and only the first source is used.  If more than one URI is
#   specified and `ca_dir_sourceselect` *is* set to `all` then all the sources
#   in the array are coppied to the target direcotry.
#
#   Certificates contained within the directories must be PEM- or DER-encoded.
#   After they are installed an Exec is called to create hash links for them.
#   If any are malformed the Exec will raise an error.
#
#   Examples:
#
#     # Use a single source directory
#     class { 'pam_pkcs11':
#       ca_dir_source => ['puppet:///modules/files/ca_files'],
#     }
#
#     # Use a primary source directory with a fallback server
#     class { 'pam_pkcs11':
#       ca_dir_source => [
#         'puppet:///modules/files/ca_files',
#         'puppet://puppet-files.example.org/modules/files/ca_files',
#       ],
#     }
#
#     # Combine the files from two source directories
#     class { 'pam_pksc11':
#       ca_dir_source => [
#         'puppet:///modules/files/ca_files',
#         'puppet:///modules/ca_certs/certs',
#       ],
#       ca_dir_sourceselect => 'all',
#     }
#
#   Default: []
#
# @param ca_dir_sourceselect
#   String
#
#   Default: 'first'
#
# @param manage_pkcs11_eventmgr
#   Boolean
#
#   Whether or not to manage the `pkcs11_eventmgr(1)`.
#
#   Default: true
#
class pam_pkcs11 (
  String        $package_name           = $pam_pkcs11::params::package_name,
  Boolean       $debug                  = false,
  Boolean       $nullok                 = false,
  Boolean       $use_first_pass         = false,
  Boolean       $try_first_pass         = false,
  Boolean       $use_authtok            = false,
  Boolean       $card_only              = false,
  Boolean       $wait_for_card          = false,
  Hash          $pkcs11_module          = {},
  Array[String] $use_mappers            = ['digest'],
  Hash          $mapper_options         = {},
  Hash          $digest_mappings        = {},
  Hash          $subject_mappings       = {},
  Hash          $uid_mappings           = {},
  Array[String] $ca_dir_source          = [],
  String        $ca_dir_sourceselect    = 'first',
  Boolean       $manage_pkcs11_eventmgr = true,
) inherits pam_pkcs11::params {
  if $ca_dir_source != [] and $facts['os']['family'] == 'RedHat' { fail('The `ca_dir_source` parameter is not supported on RedHat OS families.') }
  validate_re($ca_dir_sourceselect, '^(?:first|all)$')
  validate_bool($manage_pkcs11_eventmgr)

  $merged_pkcs11_module  = merge($pam_pkcs11::params::pkcs11_module, $pkcs11_module)

  # PKCS#11 Module option validation
  validate_string($merged_pkcs11_module['name'])
  validate_absolute_path($merged_pkcs11_module['module'])
  validate_string($merged_pkcs11_module['slot_description'])
  if $merged_pkcs11_module['slot_num'] != undef { validate_integer($merged_pkcs11_module['slot_num']) }
  if $merged_pkcs11_module['ca_dir'] != undef { validate_absolute_path($merged_pkcs11_module['ca_dir']) }
  validate_absolute_path($merged_pkcs11_module['crl_dir'])
  if $merged_pkcs11_module['nss_dir'] != undef { validate_absolute_path($merged_pkcs11_module['nss_dir']) }
  validate_bool($merged_pkcs11_module['support_threads'])
  validate_string($merged_pkcs11_module['cert_policy'])
  validate_string($merged_pkcs11_module['token_type'])

  $merged_mapper_options = deep_merge($pam_pkcs11::params::mapper_options, $mapper_options)

  # Mapper option validation (Oh, woe is me.)
  validate_bool($merged_mapper_options['digest']['debug'])
  if $merged_mapper_options['digest']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['digest']['module']) }
  validate_re($merged_mapper_options['digest']['algorithm'], '^(?:null|md2|md4|md5|sha|sha1|dss|dss1|ripemd160)$')
  validate_string($merged_mapper_options['digest']['mapfile'])
  validate_bool($merged_mapper_options['ldap']['debug'])
  validate_absolute_path($merged_mapper_options['ldap']['module'])
  validate_string($merged_mapper_options['ldap']['ldaphost'])
  validate_string($merged_mapper_options['ldap']['URI'])
  validate_integer($merged_mapper_options['ldap']['scope'], 2)
  validate_string($merged_mapper_options['ldap']['binddn'])
  validate_string($merged_mapper_options['ldap']['passwd'])
  validate_string($merged_mapper_options['ldap']['base'])
  validate_string($merged_mapper_options['ldap']['attribute'])
  validate_string($merged_mapper_options['ldap']['filter'])
  validate_re($merged_mapper_options['ldap']['ssl'], '^(?:off|on|tls|ssl)$')
  validate_absolute_path($merged_mapper_options['ldap']['tls_cacertfile'])
  if $merged_mapper_options['ldap']['tls_cacertdir'] != undef { validate_absolute_path($merged_mapper_options['ldap']['tls_cacertdir']) }
  if $merged_mapper_options['ldap']['tls_chekpeer'] != undef {
    validate_re($merged_mapper_options['ldap']['tls_checkpeer'], '^(?:never|allow|try|demand|hard)$')
  }
  if $merged_mapper_options['ldap']['tls_ciphers'] != undef { validate_string($merged_mapper_options['ldap']['tls_ciphers']) }
  if $merged_mapper_options['ldap']['tls_cert'] != undef { validate_absolute_path($merged_mapper_options['ldap']['tls_cert']) }
  if $merged_mapper_options['ldap']['tls_key'] != undef { validate_absolute_path($merged_mapper_options['ldap']['tls_key']) }
  validate_absolute_path($merged_mapper_options['ldap']['tls_randfile'])
  validate_bool($merged_mapper_options['generic']['debug'])
  if $merged_mapper_options['generic']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['generic']['module']) }
  validate_string($merged_mapper_options['generic']['mapfile'])
  validate_bool($merged_mapper_options['generic']['ignorecase'])
  validate_re($merged_mapper_options['generic']['cert_item'], '^(?:cn|subject|kpn|email|upn|uid)$')
  validate_bool($merged_mapper_options['generic']['use_getpwent'])
  validate_bool($merged_mapper_options['subject']['debug'])
  if $merged_mapper_options['subject']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['subject']['module']) }
  validate_string($merged_mapper_options['subject']['mapfile'])
  validate_bool($merged_mapper_options['subject']['ignorecase'])
  validate_bool($merged_mapper_options['openssh']['debug'])
  validate_absolute_path($merged_mapper_options['openssh']['module'])
  validate_bool($merged_mapper_options['opensc']['debug'])
  validate_absolute_path($merged_mapper_options['opensc']['module'])
  validate_bool($merged_mapper_options['pwent']['debug'])
  if $merged_mapper_options['pwent']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['pwent']['module']) }
  validate_bool($merged_mapper_options['pwent']['ignorecase'])
  validate_bool($merged_mapper_options['null']['debug'])
  if $merged_mapper_options['null']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['null']['module']) }
  validate_bool($merged_mapper_options['null']['default_match'])
  validate_string($merged_mapper_options['null']['default_user'])
  validate_bool($merged_mapper_options['cn']['debug'])
  if $merged_mapper_options['cn']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['cn']['module']) }
  validate_string($merged_mapper_options['cn']['mapfile'])
  validate_bool($merged_mapper_options['cn']['ignorecase'])
  validate_bool($merged_mapper_options['mail']['debug'])
  if $merged_mapper_options['mail']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['mail']['module']) }
  validate_string($merged_mapper_options['mail']['mapfile'])
  validate_bool($merged_mapper_options['mail']['ignorecase'])
  validate_bool($merged_mapper_options['mail']['ignoredomain'])
  validate_bool($merged_mapper_options['ms']['debug'])
  if $merged_mapper_options['ms']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['ms']['module']) }
  validate_bool($merged_mapper_options['ms']['ignorecase'])
  validate_bool($merged_mapper_options['ms']['ignoredomain'])
  validate_string($merged_mapper_options['ms']['domainname'])
  validate_bool($merged_mapper_options['krb']['debug'])
  if $merged_mapper_options['krb']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['krb']['module']) }
  validate_bool($merged_mapper_options['krb']['ignorecase'])
  validate_string($merged_mapper_options['krb']['mapfile'])
  validate_bool($merged_mapper_options['uid']['debug'])
  if $merged_mapper_options['uid']['module'] != 'internal' { validate_absolute_path($merged_mapper_options['uid']['module']) }
  validate_bool($merged_mapper_options['uid']['ignorecase'])
  validate_string($merged_mapper_options['uid']['mapfile'])

  # HACK: This doesn't work in Puppet 3.x so validation is done in the template.
  # $digest_mappings.each | String $uid, String $fingerprint | {
  #   validate_re($fingerprint, '^[[:xdigit:]]{2}(:[[:xdigit:]]{2}){18}:[[:xdigit:]]{2}$')
  # }

  include 'pam_pkcs11::install'
  include 'pam_pkcs11::config'
  if $manage_pkcs11_eventmgr == true { include 'pam_pkcs11::pkcs11_eventmgr' }
}

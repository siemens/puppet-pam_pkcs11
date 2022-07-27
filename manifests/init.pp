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
#   `pkcs11_module_base`.
#
#   Default: {}
#
# @param pkcs11_module_base
#   Hash
#
#   A hash containing the default configuration for the selected PKCS #11 module
#   that are used as a base for `pkcs11_module`.
#
#   Default: (see params.pp:pkcs11_module)
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
#   with the defaults from `mapper_options_base`.
#
#   Default: {}
#
# @param mapper_options_base
#   Hash
#
#   A nested hash with the default options for each mapper in use which are used
#   as a base for the configuration in `mapper_options`.
#
#   Default: (see params.pp:mapper_options)
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
#       ca_dir_source       => ['puppet:///modules/files/ca_files'],
#     }
#
#     # Use a primary source directory with a fallback server
#     class { 'pam_pkcs11':
#       ca_dir_source       => [
#         'puppet:///modules/files/ca_files',
#         'puppet://puppet-files.example.org/modules/files/ca_files',
#       ],
#     }
#
#     # Combine the files from two source directories
#     class { 'pam_pksc11':
#       ca_dir_source       => [
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
  Struct[
    name             => Optional[String],
    module           => Optional[Variant[Enum['internal'], Stdlib::Absolutepath]],
    slot_description => Optional[String],
    slot_num         => Optional[Integer],
    ca_dir           => Optional[Stdlib::Absolutepath],
    crl_dir          => Optional[Stdlib::Absolutepath],
    nss_dir          => Optional[Stdlib::Absolutepath],
    support_threads  => Optional[Boolean],
    cert_policy      => Optional[String],
    token_type       => Optional[String]
  ]             $pkcs11_module          = {},
  Struct[
    name             => String,
    module           => Variant[Enum['internal'], Stdlib::Absolutepath],
    slot_description => String,
    slot_num         => Optional[Integer],
    ca_dir           => Optional[Stdlib::Absolutepath],
    crl_dir          => Stdlib::Absolutepath,
    nss_dir          => Optional[Stdlib::Absolutepath],
    support_threads  => Boolean,
    cert_policy      => String,
    token_type       => String
  ]             $pkcs11_module_base     = $pam_pkcs11::params::pkcs11_module,
  Array[String] $use_mappers            = ['digest'],
  Pam_pkcs11::MapperOptionsOpt $mapper_options         = {},
  Pam_pkcs11::MapperOptions    $mapper_options_base    = $pam_pkcs11::params::mapper_options,
  Hash          $digest_mappings        = {},
  Hash          $subject_mappings       = {},
  Hash          $uid_mappings           = {},
  Array[String] $ca_dir_source          = [],
  Enum[
    'first',
  'all']        $ca_dir_sourceselect    = 'first',
  Boolean       $manage_pkcs11_eventmgr = true,
) inherits pam_pkcs11::params {
  if $ca_dir_source != [] and $facts['os']['family'] == 'RedHat' { fail('The `ca_dir_source` parameter is not supported on RedHat OS families.') }

  $merged_pkcs11_module  = merge($pkcs11_module_base, $pkcs11_module)
  $merged_mapper_options = deep_merge($mapper_options_base, $mapper_options)

  # HACK: This doesn't work in Puppet 3.x so validation is done in the template.
  # $digest_mappings.each | String $uid, String $fingerprint | {
  #   validate_re($fingerprint, '^[[:xdigit:]]{2}(:[[:xdigit:]]{2}){18}:[[:xdigit:]]{2}$')
  # }

  include 'pam_pkcs11::install'
  include 'pam_pkcs11::config'
  if $manage_pkcs11_eventmgr == true { include 'pam_pkcs11::pkcs11_eventmgr' }
}

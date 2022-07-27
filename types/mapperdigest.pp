type Pam_pkcs11::MapperDigest = Struct[
  debug     => Boolean,
  module    => Variant[Enum['internal'], Stdlib::Absolutepath],
  algorithm => Enum['null', 'md2', 'md4', 'md5', 'sha', 'sha1', 'dss', 'dss1', 'ripemd160'],
  mapfile   => Variant[Enum['none'], Stdlib::Filesource],
]

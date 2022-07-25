type Pam_pkcs11::MapperCn = Struct[
  debug      => Boolean,
  module     => Variant[Enum['internal'], Stdlib::Absolutepath],
  mapfile    => Variant[Enum['none'], Stdlib::Filesource],
  ignorecase => Boolean,
]

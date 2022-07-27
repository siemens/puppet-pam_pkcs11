type Pam_pkcs11::MapperKrb = Struct[
  debug      => Boolean,
  module     => Variant[Enum['internal'], Stdlib::Absolutepath],
  ignorecase => Boolean,
  mapfile    => Variant[Enum['none'], Stdlib::Filesource],
]

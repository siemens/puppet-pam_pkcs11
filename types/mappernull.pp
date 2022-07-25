type Pam_pkcs11::MapperNull = Struct[
  debug         => Boolean,
  module        => Variant[Enum['internal'], Stdlib::Absolutepath],
  default_match => Boolean,
  default_user  => String,
]

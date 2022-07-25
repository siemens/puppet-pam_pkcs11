type Pam_pkcs11::MapperPwent = Struct[
  debug      => Boolean,
  module     => Variant[Enum['internal'], Stdlib::Absolutepath],
  ignorecase => Boolean,
]

type Pam_pkcs11::MapperMs = Struct[
  debug        => Boolean,
  module       => Variant[Enum['internal'], Stdlib::Absolutepath],
  ignorecase   => Boolean,
  ignoredomain => Boolean,
  domainname   => String,
]

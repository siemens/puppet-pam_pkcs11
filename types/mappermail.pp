type Pam_pkcs11::MapperMail = Struct[
  debug        => Boolean,
  module       => Variant[Enum['internal'], Stdlib::Absolutepath],
  mapfile      => Variant[Enum['none'], Stdlib::Filesource],
  ignorecase   => Boolean,
  ignoredomain => Boolean,
]

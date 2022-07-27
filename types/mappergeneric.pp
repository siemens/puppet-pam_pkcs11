type Pam_pkcs11::MapperGeneric = Struct[
  debug        => Boolean,
  module       => Variant[Enum['internal'], Stdlib::Absolutepath],
  mapfile      => Variant[Enum['none'], Stdlib::Filesource],
  ignorecase   => Boolean,
  cert_item    => Enum['cn', 'subject', 'kpn', 'email', 'upn', 'uid'],
  use_getpwent => Boolean,
]

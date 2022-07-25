type Pam_pkcs11::EventAction = Struct[
  on_error => Enum['ignore', 'return', 'quit'],
  action => Array[String],
]

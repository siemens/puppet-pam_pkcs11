type Pam_pkcs11::EventCfg = Struct[
  card_insert => Pam_pkcs11::EventAction,
  card_remove => Pam_pkcs11::EventAction,
  expire_time => Pam_pkcs11::EventAction,
]

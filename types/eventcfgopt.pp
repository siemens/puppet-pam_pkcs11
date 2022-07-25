type Pam_pkcs11::EventCfgOpt = Struct[
  card_insert => Optional[Pam_pkcs11::EventAction],
  card_remove => Optional[Pam_pkcs11::EventAction],
  expire_time => Optional[Pam_pkcs11::EventAction],
]

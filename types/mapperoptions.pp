type Pam_pkcs11::MapperOptions = Struct[
    digest  => Pam_pkcs11::MapperDigest,
    ldap    => Pam_pkcs11::MapperLdap,
    generic => Pam_pkcs11::MapperGeneric,
    subject => Pam_pkcs11::MapperSubject,
    openssh => Pam_pkcs11::MapperOpenSSH,
    opensc  => Pam_pkcs11::MapperOpenSc,
    pwent   => Pam_pkcs11::MapperPwent,
    null    => Pam_pkcs11::MapperNull,
    cn      => Pam_pkcs11::MapperCn,
    mail    => Pam_pkcs11::MapperMail,
    ms      => Pam_pkcs11::MapperMs,
    krb     => Pam_pkcs11::MapperKrb,
    uid     => Pam_pkcs11::MapperUid,
]

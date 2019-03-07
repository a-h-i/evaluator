
# Dependencies

You will need to add the RPM Fusion non free repositories.
```
dnf update -y
dnf install -y policycoreutils-sandbox boost-devel git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim readline-devel postgresql-devel postgresql-contrib 
dnf install -y atool unzip lzma lzop lzip unrar lha p7zip

```

Restart your system after these updates

# Firewall Rules

Use ssh only firewall as described [here](../misc/ssh_only_firewall.md) 
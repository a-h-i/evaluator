

# Redis Deployment

There are two modes for redis deployment, one for cache and one for messaging. This is a guide to setup both of them.

Set timezone and localsettings by following[this](../misc/locale.md)

# System requriements
```
dnf update -y
dnf install -y git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim redis
```
Restart your system after these updates


# Firewall Rules
[Use this configuration](../misc/ssh_only_firewall.md)


# Configurations
Redis reads configurations from `/etc/redis.conf`
[sample cache config](cache.conf)
[sample message config](messaging.conf)

# Systemd service
Enable and start service
```
systemctl enable redis
systemctl start redis
```



# sysctl
It is your friend, learn to use it. As well as systemd and journalctl.

# Additional Settings that may work well for you

The following can be placed at `/etc/sysctl.d/max-conn.conf` (new file) changes will take affect after reboot
```
# Increase number of incoming connections
net.core.somaxconn = 4096
# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 65536

```




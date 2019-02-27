

# Network FileSystem
Assumes that our export is `/mnt/evaluator_data`

First basic setup through the following guides [firewall](ssh_only_firewall.md) [locale](locale.md) [tcp optimization](tcp_settings.md)

```bash
dnf update -y
dnf install nfs-utils
```

## Firewall config for NFS
Extra config steps required for NFS after basic firewall setup before can be found [here](nfs_firewall.md)

## Exports file

[export file](evaluator.metguc.in.exports) place in `/etc/exports.d/` directory on your nfs *server*


## Start services (server)
```bash
systemctl enable rpcbind
systemctl start rpcbind
systemctl enable nfs-server
systemctl start nfs-server

```
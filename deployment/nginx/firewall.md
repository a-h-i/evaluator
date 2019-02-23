

# Dependencies
`dnf install firewalld`

# Enable and start

```
systemctl enable firewalld
systemctl start firewalld
```


This example we will use public as our default zone

To list the services of public zone
`firewall-cmd --zone=public --list-service`

`firewall-cmd --list-all-zones` lists all zones

`firewall-cmd --get-default-zone` gets default zone name, use this zone name for the rest of the guide

we want to remove all services except ssh from the default zone, for each service we do
`firewall-cmd --zone=public --remove-service=mdns --permanent` mdns is a service

now we want to add http and https services
```
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
```

Change default target to DROP
```
firewall-cmd --zone=public --set-target=DROP --permanent
```

you want to add all interfaces to the public zone
`ifconfig` lists interfaces, ignore lo interface.
for each interface other than lo

`firewall-cmd --permanent --zone=public --add-interface=eth0` where eth0 is an interface name

then we need to change the ifup script for each interface
`vim /etc/sysconfig/network-scripts/ifcfg-eth0` again eth0 is network name
ADD or modify the line `ZONE=public`

Restart your machine

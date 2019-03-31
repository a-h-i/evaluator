

# Dependencies
`dnf install firewalld`

# Enable and start

```
systemctl enable firewalld
systemctl start firewalld
```


This example we will use public as our default zone

To list the services of public zone
`firewall-cmd --zone=public --list-services`

`firewall-cmd --list-all-zones` lists all zones

`firewall-cmd --get-default-zone` gets default zone name, use this zone name for the rest of the guide

we want to remove all services except ssh from the default zone, for each service we do
`firewall-cmd --zone=public --remove-service=mdns --permanent` mdns is a service


Change default target to DROP
```
firewall-cmd --zone=public --set-target=DROP --permanent
```

then we need to change the ifup script for each interface
`vim /etc/sysconfig/network-scripts/ifcfg-eth0` again eth0 is network name
ADD or modify the line `ZONE=public`
for each one also perform `firewall-cmd --zone=public --add-interface=eth0 --permanent`
Restart your machine


# Note
All internal communication happens over SSH tunnel and appear as local to the observer so we do not add any rules to allow those connections

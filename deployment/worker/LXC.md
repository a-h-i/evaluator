
# Introduction
We will be using priveleged containers. `su - ` to root before following the rest of the guide.

# Lxc installation
```bash
dnf install lxc lxc-templates dnsmasq
```

# Configuration

## High level overview
 - Configure a virtual bridge for LXC containers to use to communicate to the outside world, while isolating it from our network interface. That is so it can not access network resource on the evaluator cloud.
 - Configure CGroups to manage resource consumption by the container
 - Create a container to be used by the worker.
 - Setup the container so that root can ssh into it.
 - Setup the container so that java code can be run through maven.


 ### Configure a virtual bridge for LXC containers

Edit the file `/etc/sysconfig/lxc-net` change it's content to the following
```
 LXC_BRIDGE="lxcbr0"
 LXC_BRIDGE_MAC="00:16:3e:00:00:00"
 LXC_ADDR="10.0.3.1"
 LXC_NETMASK="255.255.255.0"
 LXC_NETWORK="10.0.3.0/24"
 LXC_DHCP_RANGE="10.0.3.2,10.0.3.254"
 LXC_DHCP_MAX="253"
 LXC_DHCP_CONFILE=""
 LXC_DHCP_PING="true"
 LXC_DOMAIN=""
 LXC_IPV6_ADDR=""
 LXC_IPV6_MASK=""
 LXC_IPV6_NETWORK=""
 LXC_IPV6_NAT="false"
```

Edit the file `/etc/sysconfig/lxc` change it's content to the following
```
# LXC_AUTO - whether or not to start containers at boot
LXC_AUTO="true"

# BOOTGROUPS - What groups should start on bootup?
#       Comma separated list of groups.
#       Leading comma, trailing comma or embedded double
#       comma indicates when the NULL group should be run.
# Example (default): boot the onboot group first then the NULL group
BOOTGROUPS="onboot,"

# SHUTDOWNDELAY - Wait time for a container to shut down.
#       Container shutdown can result in lengthy system
#       shutdown times.  Even 5 seconds per container can be
#       too long.
SHUTDOWNDELAY=5

# OPTIONS can be used for anything else.
#       If you want to boot everything then
#       options can be "-a" or "-a -A".
OPTIONS=

# STOPOPTS are stop options.  The can be used for anything else to stop.
#       If you want to kill containers fast, use -k
STOPOPTS="-a -A -s"

USE_LXC_BRIDGE="true"  # overridden in lxc-net

[ ! -f /etc/sysconfig/lxc-net ] || . /etc/sysconfig/lxc-net
```


Edit the file `/etc/lxc/default.conf` change it's content to the following
```
lxc.net.0.type = veth
lxc.net.0.link = lxcbr0
lxc.net.0.flags = up
lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx

```

run the following commands
```bash
systemctl enable lxc.service lxc-net.service
systemctl start lxc.service lxc-net.service
```

## Configure Cgroups
Create the file `/lib/systemd/system/system-evcont.slice`
```systemd
[Unit]
Description=Evaluator container slice
Before=slices.target



[Slice]
CPUAccounting=true
CPUWeight=80
CPUQuota=80%
CPUQuotaPeriodSec=500ms
MemoryAccounting=true
MemoryLow=0M
MemoryHigh=2048M
MemoryMax=2560M
IOAccounting=true
IOWeight=80
TasksAccounting=true
TasksMax=1024


```

Run the following commands
```
systemctl daemon-reload
systemctl start system-evcont.slice
systemctl enable system-evcont.slice
```

## Creating the container
`lxc-create -t download -n evaluator_container -- --dist=fedora --release=28 -a amd64` Feel free to change the release number as appropriate.

## Setting up auto start
Edit `/lib/systemd/system/lxc.service` and change it's content to the following
```systemd
[Unit]
Description=LXC Container Initialization and Autoboot Code
After=network.target lxc-net.service
Wants=lxc-net.service
Documentation=man:lxc-autostart man:lxc

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/lxc-autostart --all
ExecStop=/usr/bin/lxc-autostart -s --all
# Environment=BOOTUP=serial
# Environment=CONSOLETYPE=serial
Delegate=yes
StandardOutput=syslog
StandardError=syslog
Slice=system-evcont.slice
[Install]
WantedBy=multi-user.target

```

Edit `/var/lib/lxc/evaluator_container/config` and add the following
```systemd
lxc.start.auto=1
lxc.cgroup.dir=system.slice/system-evcont.slice
```

Run the following commands
```bash
systemctl daemon-reload
systemctl enable lxc-net.service lxc.service
systemctl start lxc-net.service
systemctl start lxc.service
```

Verify that it is running via `lxc-ls -f`
Should output
```
NAME                STATE   AUTOSTART GROUPS IPV4       IPV6 UNPRIVILEGED
evaluator_container RUNNING 1         -      10.0.3.226 -    false
```
If you are unable to login to the container make sure SELinux is allowing it
`cat /var/log/audit/audit.log | grep lxc | audit2why`

## Setup lxc container

```bash
lxc-attach -n evaluator_container
# you are now in the container and the prompt should have changed
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install -y openssh-server atool unzip lzma lzop lzip unrar lha p7zip curl zip less vim
curl -s "https://get.sdkman.io" | bash
exit
lxc-attach -n evaluator_container
# For Java 8 support
sdk i java 8.0.202-zulu
# For java 11 support
sdk i java 11.0.2-open
sdk i maven
sdk use maven
systemctl start sshd
systemctl enable sshd
mkdir .ssh
exit
```
Now you need to create a ssh key for root user on host machine. Take the public part and copy it to `/root/.ssh/authorized_keys` on the container.
check [ssh documentation and help](https://www.ssh.com/ssh/keygen/).

After that verify that you can login. If there is a problem check the permissions on .ssh and subcontents.


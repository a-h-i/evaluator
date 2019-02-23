
The default nginx conf has a high file limit it is suggested to increase the file limit to that value

to do so edit ` /etc/security/limits.conf`, this is the per user value
append the lines 
```
* hard nofile <limit>`
* soft nofile <limit>
```

Check that there are no conflicting declarations under /etc/security/limits.d/*.conf, as those files take precedence.

then edit `/etc/sysctl.conf`, this is the system wide value
add or change
`fs.file-max = <value>`
this should be at least 1.5 times the limit used before, 200342 is a default value.


finally edit both `/etc/systemd/system.conf` and `/etc/systemd/user.conf`
under the `[Manager]` section see [systemd-system.conf(5)](https://www.freedesktop.org/software/systemd/man/systemd-system.conf.html) for more
add or uncomment or modify the line
`DefaultLimitNOFILE=<value>` This value is per process and should be as the one used per user, generally speaking
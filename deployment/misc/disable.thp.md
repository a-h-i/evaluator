## Disabling transparent huge pages guide
Create file `/lib/systemd/system/disable_thp.service`
with content
```
[Service]
Type=simple
ExecStart=/bin/sh -c "echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled && echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag"

[Install]
WantedBy=multi-user.target


```

perform

```
systemctl enable disable_thp.service
systemctl start disable_thp.service
```

Why not boot params? grub is just there for show on VMs

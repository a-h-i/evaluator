# Set system timezone, locale and setup NTP

## timezone
`timedatectl set-timezone UTC`

## NTP 
```bash
timedatectl set-ntp yes
timedatectl set-local-rtc 0
```

## locale
`localectl set-locale LANG=en_US.utf8`

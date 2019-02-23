

# Recommended Swap

```
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

Modify `/etc/fstab` and add the following line `/swapfile swap swap defaults 0 0`

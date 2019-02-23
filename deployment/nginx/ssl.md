

using this tool [here](https://certbot.eff.org/)
Select none of the above for software and fedora system. Make sure no web servers are running before

```
dnf install certbot
certbot certonly --standalone -d evaluator.metguc.in -d metguc.in
```
certbot will then guide you step by step remember where your certificates went for later. DO NOT SHARE THESE WITH ANYONE, DOWNLOAD OR EVEN cp for that matter...
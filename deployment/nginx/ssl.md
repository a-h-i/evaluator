

using this tool [here](https://certbot.eff.org/)
Select  for software and fedora system. Make sure no web servers are running before


certbot will then guide you step by step remember where your certificates went for later. DO NOT SHARE THESE WITH ANYONE, DOWNLOAD OR EVEN cp for that matter...

`certbot -a --dns-digitalocean --dns-digitalocean-crendential /root/.digitalocean_creds -i nginx certonly -d "*.metguc.in" -d metguc.in`

/etc/letsencrypt/live/metguc.in-0001/fullchain.pem
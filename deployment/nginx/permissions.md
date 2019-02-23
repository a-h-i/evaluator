

# Permissions
`chmod -R 755 /path/to/www` this will need to be run after each deployment

# SELinux

`chcon -Rt httpd_sys_content_t /path/to/www`


after 1 attempt to connect


`grep nginx /var/log/audit/audit.log  | audit2allow -M nginx`

`semodule -i nginx.pp` then `systemctl restart nginx`


# Enable service
`systemctl enable nginx`
`systemctl start nginx`
`systemctl stop nginx`

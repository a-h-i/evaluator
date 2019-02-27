

# System requriements
```
dnf update -y
dnf install -y git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim readline-devel ruby ruby-devel
```
Restart your system after these updates


# Firewall Rules



# SSH Tunneling

We need to establish a tunnel to the PG and Cache instances

# tmpfs directory
`mkdir /var/run/evaluator`

# Log Directory
`mkdir /var/log/evaluator`

# Mailer BG Worker

Sidekiq conf [sidekiq.yml](sidekiq.yml)

start with `sidekiq -C /some/abs/path/sidekiq.yml`

You can use [this systemd service](evaluator-sidekiq.service)

# Start unicorn
`bundle e --keep-file-descriptors unicorn -c ../deployment/instance/unicorn.conf.rb -D -E none`
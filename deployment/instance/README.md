

# System requriements
```
dnf update -y
dnf install -y git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim readline-devel ruby ruby-devel argon2 postgresql-devel postgresql-contrib libsodium  
```
Restart your system after these updates


# Firewall Rules

Use ssh only firewall as described [here](../misc/ssh_only_firewall.md) 

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


# Hot reloading

```

You may replace a running instance of unicorn with a new one without
losing any incoming connections.  Doing so will reload all of your
application code, Unicorn config, Ruby executable, and all libraries.
The only things that will not change (due to OS limitations) are:

1. The path to the unicorn executable script.  If you want to change to
   a different installation of Ruby, you can modify the shebang
   line to point to your alternative interpreter.

The procedure is exactly like that of nginx:

1. Send USR2 to the master process

2. Check your process manager or pid files to see if a new master spawned
   successfully.  If you're using a pid file, the old process will have
   ".oldbin" appended to its path.  You should have two master instances
   of unicorn running now, both of which will have workers servicing
   requests.  Your process tree should look something like this:

     unicorn master (old)
     \_ unicorn worker[0]
     \_ unicorn worker[1]
     \_ unicorn worker[2]
     \_ unicorn worker[3]
     \_ unicorn master
        \_ unicorn worker[0]
        \_ unicorn worker[1]
        \_ unicorn worker[2]
        \_ unicorn worker[3]

3. You can now send WINCH to the old master process so only the new workers
   serve requests.  If your unicorn process is bound to an interactive
   terminal, you can skip this step.  Step 5 will be more difficult but
   you can also skip it if your process is not daemonized.

4. You should now ensure that everything is running correctly with the
   new workers as the old workers die off.

5. If everything seems ok, then send QUIT to the old master.  You're done!

   If something is broken, then send HUP to the old master to reload
   the config and restart its workers.  Then send QUIT to the new master
   process.



```
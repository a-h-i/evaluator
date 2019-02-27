

# Getting Start
This guide and application were developed for version 10.x of PG, however it is compatible with 11 and will most likely be compatible with future releases

This file will guide you through setting up your postgresql instance

There are two main configuration files that we will be managing. `pg_hba.conf` and `postgresql.conf`

Setup swap by following [this](../misc/swap.md)

Set timezone and localsettings by following[this](../misc/locale.md)

## Installation

```bash
dnf update
dnf install policycoreutils-python-utils make git autoconf gcc gcc-c++ openssl openssl-devel curl firewalld vim node-gyp readline-devel cmake
dnf install postgresql-server postgresql-contrib
```


For the OS's packaged version `dnf install postgresql-server postgresql-contrib`
If OS provides an incompatible version, consider building from source. Such documentation can be found on the postgres server, the rest of the guide will be unchanged.
You should restart your vm now

## Becoming postgres user
as root `su - postgres` THis is useful for connecting to the db locally over unix socket and editing config files.


## Initalizing DB
```bash
PGSETUP_INITDB_OPTIONS="-E UTF8" postgresql-setup --initdb --unit postgresql 

```

## Configure access control
`pg_hba.conf ` determines how clients connect to your instance, the sample config can be found [here](pg_hba.conf) it uses peer authentication for unix domain sockets and requires md5 password validation for anything else. The location of pg_hba is `/var/lib/pgsql/data/pg_hba.conf` it should belong to postgres:postgres  and only postgres user should be able to modify it. A good way to ensure permissions are not changed is to edit it as postgres.


## Configure Database
`/var/lib/pgsql/data/postgresql.conf` is the other configuration file, it should have the same ownership and permission as pg_hba.con and recommend editing using the same method. A sample is provided [here](postgresql.conf)

## Disable THP
Follow [this guide](../misc/disable.thp.md)

## Enabling and starting db
```bash
systemctl enable postgresql
systemctl start postgresql
```


## Creating ROLEs
as postgres user run `psql`

Generate a random password that is preferrably long. I suggest ruby SecureRandom or /dev/random on your local machine as that is as close to true random as machines can get. Store that random password on your local machine, securely... Do not share it.

`CREATE ROLE evaluator_api WITH CREATEDB LOGIN PASSWORD password_variable_in_quotes;

## Configure Firewall
[Use this configuration](../misc/ssh_only_firewall.md)
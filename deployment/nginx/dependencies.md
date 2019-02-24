
```bash
dnf update
dnf install nginx make git autoconf gcc gcc-c++ openssl curl firewalld vim node-gyp readline-devel cmake policycoreutils-python-utils
```
For frontend development make sure to install nvm as well to manage node versions

```bash
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source /home/vagrant/.bashrc
nvm install v11.6.0
nvm alias default v11.6.0
```

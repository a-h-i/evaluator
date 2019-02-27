# How to setup rbenv

```bash
dnf install -y git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim readline-devel ruby ruby-devel
dnf install -y bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
mkdir -p "$(rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 2.6.1
rbenv global 2.6.1
gem install bundler
rbenv rehash
```


# Dependencies
```bash
dnf update -y
dnf install -y policycoreutils-sandbox boost-devel git make gcc cmake policycoreutils-python-utils autoconf gcc-c++ openssl openssl-devel curl firewalld vim readline-devel postgresql-devel postgresql-contrib libxml2 libxml2-devel
dnf install -y atool unzip lzma lzop lzip unrar lha p7zip 

```


# Building
```bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE ../ 
make
```

# Installing
after building `cd` into the build directory and run `make install` you may need to be super user/root.


# Usage
This library uses libxml2 you need to initialize the parser and free it before using this library.
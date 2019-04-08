

# Dependencies
```bash
dnf update -y
dnf install -y boost boost-devel git make gcc cmake autoconf gcc-c++ openssl curl firewalld vim readline-devel libxml2 libxml2-devel tbb tbb-devel libssh-devel
dnf install -y atool unzip lzma lzop lzip unrar lha p7zip 

```


# Building
```bash
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr ../ 
make
```
Cmake build types `RELEASE`, `DEBUG` and `PROFILE` the default is `DEBUG`. Please only install the `RELEASE` version.
# Installing
after building `cd` into the build directory and run `make install` you may need to be super user/root.


# Usage
This library uses libxml2 you need to initialize the parser and free it before using this library.
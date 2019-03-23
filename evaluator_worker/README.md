

# Dependencies
```bash
dnf update -y
dnf install -y boost boost-devel git make gcc cmake autoconf gcc-c++ openssl curl firewalld vim postgres-devel hiredis-devel libuv libuv-devel

```
Requires [evspeclib](../evaluator_spec_lib/README.md)



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


# Signals
Signal `TERM` gracefully terminates the worker.
Signal `SIGUSER1` reloads coniguration file and restarts the worker (loading new code).


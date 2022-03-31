#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${BUSYBOX}

make ARCH=aarch64 CROSS_COMPILE=${CC} defconfig
make ARCH=aarch64 CROSS_COMPILE=${CC} menuconfig
make ARCH=aarch64 CROSS_COMPILE=${CC}
make ARCH=aarch64 CROSS_COMPILE=${CC} install
 
popd

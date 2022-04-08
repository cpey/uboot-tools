#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${ATF}

export CROSS_COMPILE=${CC}
make PLAT=qemu ARCH=aarch32 ARM_ARCH_MAJOR=7 all

popd

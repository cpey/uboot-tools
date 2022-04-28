#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

pushd `pwd`
cd ${ATF}

export CROSS_COMPILE=${CC64}
make PLAT=qemu ARCH=aarch64 ARM_ARCH_MAJOR=8 all

popd

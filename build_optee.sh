#!/bin/bash

set -ex

source config.sh

pushd `pwd`

export CROSS_COMPILE=${CC64}
export AARCH64_CROSS_COMPILE=${CC64}

cd ${OPTEE}/optee_examples/hello_world/ta
make

cd ${OPTEE}/optee_examples/hello_world/host
make

exit

cd ${OPTEE}/build

export CROSS_COMPILE=${CC64}
export AARCH64_CROSS_COMPILE=${CC64}
make toolchains
#make run
make QEMU_VIRTFS_ENABLE=y CFG_TEE_RAM_VA_SIZE=0x00300000

popd


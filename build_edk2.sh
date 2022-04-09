#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${EDK2}

make -C BaseTools
source edksetup.sh
export GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
build -a AARCH64 -t GCC5 -p ArmVirtPkg/ArmVirtQemuKernel.dsc

popd

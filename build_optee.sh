#!/bin/bash

set -ex

source config.sh

pushd $(pwd)
cd ${OPTEE}/build

export CROSS_COMPILE=${CC64}
export AARCH64_CROSS_COMPILE=${CC64}

make toolchains
make -j$(nproc)

popd

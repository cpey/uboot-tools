#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${QEMU}

[[ -d build ]] && rm -r build
mkdir build && cd build

../configure
make -j`nproc`

popd

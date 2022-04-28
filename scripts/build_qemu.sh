#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

pushd `pwd`
cd ${QEMU}

[[ -d build ]] && rm -r build
mkdir build && cd build

../configure
make -j`nproc`

popd

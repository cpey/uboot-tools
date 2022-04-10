#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${OPTEE}/build

export CROSS_COMPILE=${CC}
make toolchains
make run

popd


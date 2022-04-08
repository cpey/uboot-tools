#!/bin/bash

set -ex

source config.sh

pushd `pwd`
cd ${OPTEE}

export CROSS_COMPILE=${CC}

popd


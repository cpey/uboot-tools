#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

GCC=${CC}-gcc

pushd `pwd`
cd ${TCPDUMP}

[[ -d ${TCPDUMP_INST_DIR} ]] && rm -r ${TCPDUMP_INST_DIR}
mkdir ${TCPDUMP_INST_DIR}

CFLAGS=-static CC=${GCC} ./configure --build=x86_64-linux-gnu --host=arm-none-linux-gnueabihf --prefix=${TCPDUMP_INST_DIR}
make
make install
popd

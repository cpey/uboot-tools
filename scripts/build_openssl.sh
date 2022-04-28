#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

pushd `pwd`
cd ${OPENSSL}

[[ -d ${OPENSSL_INST_DIR} ]] && rm -r ${OPENSSL_INST_DIR}
mkdir ${OPENSSL_INST_DIR}

perl Configure linux-armv4 shared no-weak-ssl-ciphers -DL_ENDIAN --prefix=${OPENSSL_INST_DIR} --openssldir=${OPENSSL_INST_DIR} --cross-compile-prefix=${CC} --release
make all
make install

popd

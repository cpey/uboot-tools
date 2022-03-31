#!/bin/bash

set -ex

source config.sh

INSTALL_DIR=install
BUILD_DIR=build

HOST_ARG=""
CLEAN=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-c|--clean-buildT)
			CLEAN=1
			shift
			;;
		-h|--host)
			HOST_ARG=$2
			shift
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

pushd `pwd`
cd ${GLIBC}
[[ -n ${CLEAN} ]] && [[ -d ${BUILD_DIR} ]] && rm -r ${BUILD_DIR}
[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}
[[ -d ${INSTALL_DIR} ]] && rm -r ${INSTALL_DIR}
cd ${BUILD_DIR}

if [[ ${HOST_ARG} == "aarch64" ]]; then
	HOST=aarch64-linux-gnu
else
	HOST=arm-linux-gnueabihf
fi

CXX=${CC}g++ \
CC=${CC}gcc \
LD=${CC}ld \
AR=${CC}ar \
RANLIB=${CC}ranlib \
../configure --host=${HOST} --prefix= --build=i686-linux-gnu
make -j`nproc`
make install install_root=${GLIBC}/${INSTALL_DIR}

popd

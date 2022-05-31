#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

INSTALL_DIR=install
BUILD_DIR=build

HOST_ARG=""
CLEAN=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-c|--clean-build)
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

CROSSCOMPILE=0
if [[ ${HOST_ARG} == "aarch64" ]]; then
	HOST=aarch64-linux-gnu
    BUILD=i686-linux-gnu
    CROSSCOMPILE=1
elif [[ ${HOST_ARG} == "arm" ]]; then
	HOST=arm-linux-gnueabihf
    BUILD=i686-linux-gnu
    CROSSCOMPILE=1
else
	HOST=x86_64-linux-gnu
fi

if [[ CROSSCOMPILE -eq 1 ]]; then
	CXX=${CC}g++ \
	CC=${CC}gcc \
	LD=${CC}ld \
	AR=${CC}ar \
	RANLIB=${CC}ranlib \
	../configure --host=${HOST} --prefix= --build=${BUILD}
else
	CXX=g++ \
	CC=gcc \
	LD=ld \
	AR=ar \
	RANLIB=ranlib \
	../configure --host=${HOST} --prefix=
fi
make -j`nproc`
make install install_root=${GLIBC}/${INSTALL_DIR}

popd

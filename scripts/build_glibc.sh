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
		-d|--disable-werror)
			OPTIONS=--disable-werror
			shift
			;;
		-h|--host)
			HOST_ARG=$2
			shift
			shift
			;;
		-i|--install-dir)
			INSTALL_DIR=$2
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
[[ ${CLEAN} -eq 1 ]] && [[ -d ${BUILD_DIR} ]] && rm -r ${BUILD_DIR}
[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}
[[ -d ${INSTALL_DIR} ]] && rm -r ${INSTALL_DIR}
cd ${BUILD_DIR}

CROSSCOMPILE=0
ARMCOMPILER=0
if [[ ${HOST_ARG} == "aarch64" ]]; then
	HOST=aarch64-linux-gnu
	BUILD=i686-linux-gnu
	CROSSCOMPILE=1
	ARMCOMPILER=1
elif [[ ${HOST_ARG} == "arm" ]]; then
	HOST=arm-linux-gnueabihf
	BUILD=i686-linux-gnu
	CROSSCOMPILE=1
	ARMCOMPILER=1
elif [[ ${HOST_ARG} == "i686" ]]; then
	HOST=i686-linux-gnu
	BUILD=x86_64-linux-gnu
	CROSSCOMPILE=1
else
	HOST=x86_64-linux-gnu
fi

if [[ ${CROSSCOMPILE} -eq 1 ]]; then
	MODE=""
	if [[ ${ARMCOMPILER} -eq 0 ]]; then
		CC=/usr/bin/
		MODE=-m32
	fi
	CXX="${CC}g++ ${MODE}" \
	CC="${CC}gcc ${MODE}" \
	LD=${CC}ld \
	AR=${CC}ar \
	RANLIB=${CC}ranlib \
	../configure --build=${BUILD} --host=${HOST} ${OPTIONS} --prefix=
else
	LIBS="-lstat" \
	../configure --host=${HOST} ${OPTIONS} --prefix=
fi
make -j`nproc`
make install install_root=${GLIBC}/${INSTALL_DIR}

popd

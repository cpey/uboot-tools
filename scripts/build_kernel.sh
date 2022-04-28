#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

CONFIG=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-a|--ARCH)
			ARCH=$2
			shift
			shift
			;;
		-c|--CONFIG)
			CONFIG=1
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

function get_config ()
{
	if [[ ! -n ${ARCH} ]]; then
		ARCH="arm"
	fi

	if [[ $ARCH == "arm" ]]; then
		cc=${CC}
		src=${LINUX}
		config=vexpress_defconfig
		arch=arm
		target=zImage
	elif [[ $ARCH == "aarch64" ]]; then
		cc=${CC64}
		src=${LINUX64}
		config=defconfig
		arch=arm64
		target=Image
	else
		echo "Unsupported architecture"
		exit -1
	fi
}

get_config

pushd `pwd`
cd ${src}

if [[ ${CONFIG} -eq 1 ]]; then
make mrproper
make ARCH=${arch} ${config}
make ARCH=${arch} menuconfig
fi

 Generate kernel image as zImage and necessary dtb files
make ARCH=${arch} CROSS_COMPILE=${cc} -j`nproc` ${target} dtbs

if [[ ${arch} == "arm" ]]; then
    # Transform zImage to use with u-boot
    make ARCH=${arch} CROSS_COMPILE=${cc} -j `nproc` uImage LOADADDR=0x60008000
fi

# Build dynamic modules and copy to suitable destination
make ARCH=${arch} CROSS_COMPILE=${cc} -j`nproc` modules
make ARCH=${arch} CROSS_COMPILE=${cc} -j`nproc` modules_install INSTALL_MOD_PATH=${LINUX_MODULES_DIR}

popd

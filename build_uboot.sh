#!/bin/bash
set -e

CC=/opt/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
ROOT_DIR=`pwd`
BUILD_DIR=build
UBOOT_DIR=u-boot
VBOOT_DIR=${ROOT_DIR}/verified-boot/out2

SECURE_BOOT=0
MENUCONFIG=0
CLEAN_BUILD=0
QEMU_CONFIG=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        -s|--secure)
            SECURE_BOOT=1
            shift
            ;;
        -m|--menuconfig)
            MENUCONFIG=1
            shift
            ;;
        -q|--qemu)
            QEMU_CONFIG=1
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

pushd `pwd`
cd ${UBOOT_DIR}

if [[ ${SECURE_BOOT} -eq 1 ]]; then
	make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} EXT_DTB=${VBOOT_DIR}/vexpress-v2p-ca9-pubkey.dtb -j`nproc`
	exit
fi

if [[ ${CLEAN_BUILD} -eq 1 ]]; then
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} distclean
    if [[ ${QEMU_CONFIG} -eq 1 ]]; then
        make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} qemu_arm_defconfig
    else
        make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} vexpress_ca9x4_defconfig
    fi
fi
if [[ ${MENUCONFIG} -eq 1 ]]; then
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} menuconfig
fi

make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} -j`nproc`

popd

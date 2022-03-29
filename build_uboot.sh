#!/bin/bash
set -e

source config.sh

BUILD_DIR=build

SECURE_BOOT=0
MENUCONFIG=0
CLEAN_BUILD=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
       -d|--defconfig)
            UBOOT_CONFIG=$2
            shift
            shift
            ;;
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
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

pushd `pwd`
cd ${UBOOT}

if [[ ${SECURE_BOOT} -eq 1 ]]; then
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} EXT_DTB=${VBOOT}/${VBOOT_OUT}/${VBOOT_UBOOT_DTB_PKEY} -j`nproc`
    popd
    exit 0
fi

if [[ ${CLEAN_BUILD} -eq 1 ]]; then
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} distclean
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} ${UBOOT_CONFIG}
fi

if [[ ${MENUCONFIG} -eq 1 ]]; then
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} menuconfig
    make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} savedefconfig
fi

make O=${BUILD_DIR} ARCH=arm CROSS_COMPILE=${CC} -j`nproc`

popd

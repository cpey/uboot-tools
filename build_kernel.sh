#!/bin/bash

CC=/opt/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
LINUX=/home/cpey/dev/src/linux
MODULES_INST_DIR=build

pushd `pwd`
cd ${LINUX}

CONFIG=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
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

if [[ ${CONFIG} -eq 1 ]]; then
make mrproper
make ARCH=arm vexpress_defconfig
make ARCH=arm menuconfig
exit
fi

# Generate kernel image as zImage and necessary dtb files
make ARCH=arm CROSS_COMPILE=${CC} -j`nproc` zImage dtbs

# Transform zImage to use with u-boot 
make ARCH=arm CROSS_COMPILE=${CC} -j `nproc` uImage LOADADDR=0x60008000

# Build dynamic modules and copy to suitable destination
make ARCH=arm CROSS_COMPILE=${CC} -j`nproc` modules
make ARCH=arm CROSS_COMPILE=${CC} -j`nproc` modules_install INSTALL_MOD_PATH=${MODULES_INST_DIR}

popd

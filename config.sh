#!/bin/bash

ROOT_DIR=`pwd`

# sdcard
OUT_DIR=out
DEV=/dev/loop0
DEV_FILE=${OUT_DIR}/loop
SDCARD_MOUNT_POINT=sdcard
ROOTFS=`pwd`/../debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar

# Compiler
CC=/opt/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-

# Linux
LINUX=/home/cpey/dev/src/linux
LINUX_BIN=arch/arm/boot/zImage
LINUX_DTB=arch/arm/boot/dts/vexpress-v2p-ca9.dtb

# U-Boot
UBOOT=`pwd`/u-boot
UBOOT_CONFIG=vexpress_ca9x4_defconfig
UBOOT_BIN=build/u-boot
UBOOT_DTB=build/arch/arm/dts/vexpress-v2p-ca9.dtb

# Verified boot
VBOOT=${ROOT_DIR}/verified-boot
VBOOT_OUT=out2
VBOOT_UBOOT_DTB_PKEY=vexpress-v2p-ca9-pubkey.dtb
ECDSA_PKEY_DTB=ecdsa_public_key.dtb
MKIMAGE_BIN=${UBOOT}/build/tools/mkimage

# Sign
KERNEL_IMG=${LINUX}/arch/arm/boot/uImage

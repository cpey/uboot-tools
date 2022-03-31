#!/bin/bash

ROOT_DIR=`pwd`
QEMU_BIN=qemu-system-arm

# sdcard
OUT_DIR=out
DEV_NAME=loop0
DEV=/dev/${DEV_NAME}
DEV_FILE=${OUT_DIR}/loop
SDCARD_MOUNT_POINT=sdcard
ROOTFS=`pwd`/../debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar

# Compiler
CC=~/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-

# Linux
LINUX=~/repos/linux
LINUX_BIN=arch/arm/boot/zImage
LINUX_DTB=arch/arm/boot/dts/vexpress-v2p-ca9.dtb

# U-Boot
UBOOT=~/repos/u-boot
UBOOT_CONFIG=vexpress_ca9x4_defconfig
UBOOT_BIN=build/u-boot
UBOOT_DTB=build/arch/arm/dts/vexpress-v2p-ca9.dtb

# BusyBox
BUSYBOX=~/repos/busybox
BUSYBOX_INST=${BUSYBOX}/_install

# glibc
GLIBC=~/repos/glibc
GLIBC_INST=${GLIBC}/install

# initramfs
INITRAMFS_TREE=${OUT_DIR}/arm-busybox
INITRAMFS_CPIO=initramfs-busybox-arm.cpio.gz

# Verified boot
VBOOT=${ROOT_DIR}/verified-boot
VBOOT_OUT=out2
VBOOT_UBOOT_DTB_PKEY=vexpress-v2p-ca9-pubkey.dtb
ECDSA_PKEY_DTB=ecdsa_public_key.dtb
MKIMAGE_BIN=${UBOOT}/build/tools/mkimage

# Sign
KERNEL_IMG=${LINUX}/arch/arm/boot/uImage

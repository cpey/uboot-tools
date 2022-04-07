#!/bin/bash

ROOT_DIR=`pwd`
OUT_DIR=out
QEMU_BIN=~carlesp/bin/qemu-system-arm
ROOTFS=~/repos/debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar

# Compiler
CC=~/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
CC_LIB=~/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/arm-none-linux-gnueabihf/lib

# sdcard
DEV_NAME=loop0
DEV=/dev/${DEV_NAME}
DEV_FILE=${OUT_DIR}/loop
DEV_FILE_N_ROOTFS=${OUT_DIR}/loop_n_rootfs
SDCARD_MOUNT_POINT=sdcard

# Rootfs
DEV_ROOTFS_NAME=loop1
DEV_ROOTFS=/dev/${DEV_ROOTFS_NAME}
OUT_DIR_ROOTFS=${OUT_DIR}/rootfs_images
ROOTFS_IMG=rootfs.img
DEV_FILE_ROOTFS=${OUT_DIR_ROOTFS}/${ROOTFS_IMG}

# Linux
LINUX=~/repos/linux
LINUX_BIN=arch/arm/boot/zImage
LINUX_DTB=arch/arm/boot/dts/vexpress-v2p-ca9.dtb
LINUX_MODULES_DIR=build

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
VBOOT_OUT=${OUT_DIR}/verified-boot-out
VBOOT_UBOOT_DTB_PKEY=vexpress-v2p-ca9-pubkey.dtb
ECDSA_PKEY_DTB=ecdsa_public_key.dtb
MKIMAGE_BIN=${UBOOT}/build/tools/mkimage

# OpenSSL
OPENSSL=~/repos/openssl
OPENSSL_INST_DIR=${OPENSSL}/build

# Sign
SIGN_DIR=${OUT_DIR}/signatures
KERNEL_IMG=${LINUX}/arch/arm/boot/uImage

# Init scripts
INIT_SC_DIR=init-scripts
DEFAULT_INIT=init_to_rootfs.sh

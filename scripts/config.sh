#!/bin/bash

ROOT_DIR=$(dirname $0)/..
OUT_DIR=${ROOT_DIR}/out
# Root File System from https://rcn-ee.com/rootfs/eewiki/minfs/
ROOTFS=~/repos/debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar

# QEMU
QEMU=~/repos/qemu
QEMU_BIN_ARM=${QEMU}/build/qemu-system-arm
QEMU_BIN_AARCH64=${QEMU}/build/qemu-system-aarch64

# Compiler
CC=~/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-
CC_LIB=~/toolchains/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/arm-none-linux-gnueabihf/lib
CC64=~/toolchains/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-

# sdcard
DEV_NAME=loop0
DEV=/dev/${DEV_NAME}
DEV_FILE=${OUT_DIR}/loop
DEV_FILE_N_ROOTFS=${OUT_DIR}/loop_n_rootfs
SDCARD_MOUNT_POINT=${ROOT_DIR}/sdcard

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

# Linux AARCH64
LINUX64=~/repos/linux_aarch64
LINUX64_BIN=arch/arm64/boot/Image

# Arm Trusted Firmware
ATF=~/repos/trusted-firmware-a
ATF_BIN_DIR=~/repos/trusted-firmware-a/build/qemu/release

# OPTEE OS
OPTEE=~/repos/optee-qemu
OPTEE_ROOTFS=~/repos/optee-qemu
OPTEE_CLIENT=${OPTEE}/optee_client
OPTEE_EXAMPLES=${OPTEE}/optee_examples
OPTEE_OS=${OPTEE}/optee_os

# edk2
EDK2=~/repos/edk2
EDK2_BIN=Build/ArmVirtQemuKernel-AARCH64/DEBUG_GCC5/FV/QEMU_EFI.fd

# BuildRoot
BUILDROOT=~/repos/buildroot
BUILDROOT_TAG=2022.02
BUILDROOT_IMG=output/images/rootfs.cpio.gz

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
RSA_PKEY_DTB=rsa_public_key.dtb
MKIMAGE_BIN=${UBOOT}/build/tools/mkimage

# OpenSSL
OPENSSL=~/repos/openssl
OPENSSL_INST_DIR=${OPENSSL}/build

# Sudo
SUDO=~/repos/sudo
SUDO_INST_DIR=${SUDO}/build

# Sign
SIGN_DIR=${OUT_DIR}/signatures
KERNEL_IMG=${LINUX}/arch/arm/boot/uImage

# Init scripts
INIT_SC_DIR=${ROOT_DIR}/init
DEFAULT_INIT=init_to_rootfs.sh

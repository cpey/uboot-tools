#!/bin/bash

set -x

OUT_DIR=~/tools/rootfs_images
DEV=/dev/loop1
ROOTFS=~/repos/debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar
DEV_FILE=${OUT_DIR}/loop_rootfs_qemu
DEV_SIZE_G=1
MOUNT_POINT=rootfs

OUT=$(losetup -l | { grep ${DEV} || true; })
[[ -n ${OUT} ]] && sudo losetup -d ${DEV} || echo loop0 device available

function setup_device ()
{
    touch ${DEV_FILE}
    dd if=/dev/zero of=${DEV_FILE} bs=256 count=$((${DEV_SIZE_G} * 1024 ** 3 / 256))
    sudo losetup -P ${DEV} ${DEV_FILE}
    sleep 1
    sudo mkfs.ext4 ${DEV}
}

# setup_device_qemu is functionally equivalent to setup_device
function setup_device_qemu ()
{
    qemu-img create -f raw ${DEV_FILE} 1G
    mkfs.ext4 ${DEV_FILE}
    sudo losetup -P ${DEV} ${DEV_FILE}
}

function copy_rootfs ()
{
    sudo mount ${DEV} ${MOUNT_POINT}
    sudo tar xvf ${ROOTFS} -C ${MOUNT_POINT}
    sync
    sudo umount ${DEV}
}

[[ ! -d ${OUT_DIR} ]] && mkdir ${OUT_DIR}
[[ -d ${MOUNT_POINT} ]] && rm -r ${MOUNT_POINT}
mkdir ${MOUNT_POINT}
setup_device
copy_rootfs
sudo losetup -d ${DEV}
rm -r ${MOUNT_POINT}

#!/bin/bash

set -x

source config.sh

DEV_SIZE_G=1
MOUNT_POINT=rootfs

OUT=$(losetup -l | { grep ${DEV_ROOTFS} || true; })
[[ -n ${OUT} ]] && sudo losetup -d ${DEV_ROOTFS} || echo ${DEV_ROOTFS_NAME} device available

function setup_device ()
{
    touch ${DEV_FILE_ROOTFS}
    dd if=/dev/zero of=${DEV_FILE_ROOTFS} bs=256 count=$((${DEV_SIZE_G} * 1024 ** 3 / 256))
    sudo losetup -P ${DEV_ROOTFS} ${DEV_FILE_ROOTFS}
    sleep 1
    sudo mkfs.ext4 ${DEV_ROOTFS}
}

# setup_device_qemu is functionally equivalent to setup_device
function setup_device_qemu ()
{
    qemu-img create -f raw ${DEV_FILE_ROOTFS} 1G
    mkfs.ext4 ${DEV_FILE_ROOTFS}
    sudo losetup -P ${DEV_ROOTFS} ${DEV_FILE_ROOTFS}
}

function copy_rootfs ()
{
    sudo mount ${DEV_ROOTFS} ${MOUNT_POINT}
    sudo tar xvf ${ROOTFS} -C ${MOUNT_POINT}
    sync
    sudo umount ${DEV_ROOTFS}
}

[[ ! -d ${OUT_DIR_ROOTFS} ]] && mkdir ${OUT_DIR_ROOTFS}
[[ -d ${MOUNT_POINT} ]] && rm -r ${MOUNT_POINT}
mkdir ${MOUNT_POINT}
setup_device
copy_rootfs
sudo losetup -d ${DEV_ROOTFS}
rm -r ${MOUNT_POINT}

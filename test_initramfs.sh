#!/bin/bash

source config.sh

./boot_qemu_uboot.sh -s \
	-k ${LINUX}/${LINUX_BIN} \
	-r ${DEV_FILE_N_ROOTFS} \
	-d ${LINUX}/${LINUX_DTB} \
	-i ${OUT_DIR}/${INITRAMFS_CPIO} \
    -f ${DEV_FILE_N_ROOTFS}

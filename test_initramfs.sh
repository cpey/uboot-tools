#!/bin/bash

source config.sh

./boot_qemu.sh -s \
	-k ${LINUX}/${LINUX_BIN} \
	-r ${DEV_FILE_N_ROOTFS} \
	-d ${LINUX}/${LINUX_DTB} \
	-i ${OUT_DIR}/${INITRAMFS_CPIO}

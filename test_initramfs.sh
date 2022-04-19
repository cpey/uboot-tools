#!/bin/bash

source config.sh

./boot_qemu_uboot.sh -s \
	-k ${LINUX}/${LINUX_BIN} \
	-r ${DEV_FILE_N_ROOTFS} \
	-d ${LINUX}/${LINUX_DTB} \
	-i ${OUT_DIR}/${INITRAMFS_CPIO} \
    -f ${DEV_FILE_N_ROOTFS} \
    -c "sign=MEUCIQDX+hAGYonn5PNjBBWSMPE8MQHuUnNxceGmjvE0a21iEQIgG1lbZgj4x4crSQYUjKoaokO5AXPvtPHtqQ37sBECZ2g= pkey=MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAE9KHGrATyRRPFrAdkSLPYt8mZwuAZsTz/P+HJJDH30l+073t5E56+p/7C4qN41YfNpqUMHsxTPxunDC/5O2JZYg=="

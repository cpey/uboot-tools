#!/bin/bash

source config.sh

SKIP_UBOOT=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -s|--skip-uboot)
            SKIP_UBOOT=1
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

if [[ ${SKIP_UBOOT} -eq 1 ]]; then
	sudo mount -o loop,rw ${DEV_FILE} ${SDCARD_MOUNT_POINT}

	sudo qemu-system-aarch64 -M vexpress-a9 -m 1024 \
		-serial stdio \
		-kernel sdcard/zImage \
		-dtb sdcard/vexpress-v2p-ca9.dtb \
		-sd file=sdcard/rootfs.img,format=raw \
		-append "root=/dev/mmcblk0 rw rootfstype=ext4 console=ttyAMA0" \
		-curses
else
	# --------------------------------
	# U-Boot commands for split images
	# --------------------------------
	# => fatload mmc 0:0 0x80200000 uImage
	# => fatload mmc 0:0 0x80100000 vexpress-v2p-ca9.dtb
	# => setenv bootargs 'root=/dev/mmcblk0p1 rw rootfstype=ext4 console=ttyAMA0'
	# => bootm 0x80200000 - 0x80100000

	# -----------------------------------
	# U-Boot commands to boot a FIT image
	# -----------------------------------
	# => fatload mmc 0:0 0x82000000 image.fit
	# => setenv bootargs 'root=/dev/mmcblk0p1 rw rootfstype=ext4 console=ttyAMA0'
	# => bootm 0x82000000
	sudo qemu-system-arm -M vexpress-a9 -sd ${DEV_FILE} -m 1024 \
		-serial stdio \
		-kernel ${UBOOT}/${UBOOT_BIN} \
		-audiodev id=none,driver=none \
		-display none
fi

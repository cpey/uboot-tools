#!/bin/bash

UBOOT=u-boot

FIT=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-f|--FIT)
			FIT=1
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

# Update U-Boot configs and re-build sdcard.img
cp ${UBOOT}/.config.save ${UBOOT}/build/.config
./build_uboot.sh -m
if [[ ${FIT} -eq 1 ]]; then
	./create_vboot_images.sh
	./build_uboot.sh -s
	./create_sdcard_image_rootfs.sh -f
else
	./create_sdcard_image_rootfs.sh
fi

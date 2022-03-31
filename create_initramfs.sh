#!/bin/bash

set -ex

source config.sh

NEW_BUILD=1
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-n|--no-update)
			NEW_BUILD=0
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

pushd `pwd`

function create_initramfs_tree ()
{
	[[ -d ${INITRAMFS_TREE} ]] && rm -r ${INITRAMFS_TREE}
	mkdir ${INITRAMFS_TREE}
	cd ${INITRAMFS_TREE}
	mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin}}
	cp -av ${BUSYBOX_INST}/* .
	cp -av ${GLIBC_INST}/* .

	# init
	cat > init <<-EOF
	#!/bin/sh

	mount -t proc none /proc
	mount -t sysfs none /sys

	echo -e "\nBoot took \$(cut -d' ' -f1 /proc/uptime) seconds\n"

	exec /bin/sh
	EOF
	chmod +x init
}

if [[ ${NEW_BUILD} -eq 1 ]]; then
	create_initramfs_tree
else
	cd ${INITRAMFS_TREE}
fi

# generate cpio
find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 > ../${INITRAMFS_CPIO}

popd

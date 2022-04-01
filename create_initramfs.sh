#!/bin/bash

set -ex

source config.sh

NEW_BUILD=1
GET_SHELL=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-n|--no-update)
			NEW_BUILD=0
			shift
			;;
		-s|--shell)
			GET_SHELL=1
			shift
			;;
		-i|--init)
			CUSTOM_SC=$2
			shift
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

pushd `pwd`

function get_init_script ()
{
	[[ -n ${CUSTOM_SC} ]] && sc=${CUSTOM_SC} && return
	sc=${DEFAULT_SC}
	if [[ ${GET_SHELL} -eq 1 ]]; then
		sc=shell.sh
	fi
}

function create_initramfs_tree ()
{
	[[ -d ${INITRAMFS_TREE} ]] && rm -r ${INITRAMFS_TREE}
	mkdir ${INITRAMFS_TREE}
	cd ${INITRAMFS_TREE}
	mkdir -pv {bin,sbin,etc,proc,sys,usr/{bin,sbin},mnt}
	cp -av ${BUSYBOX_INST}/* .
	cp -av ${GLIBC_INST}/* .

	# init
	get_init_script
	cp ${ROOT_DIR}/${INIT_SC_DIR}/${sc} init
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

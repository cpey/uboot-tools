#!/bin/bash
set -ex

source config.sh

ATF_FILES=()
function set_atf_links () 
{
	for i in `ls ${ATF_BIN_DIR}/*.bin`; do
		if [[ ! -e $(basename $i) ]]; then
			ln -s $i .
		fi
		ATF_FILES+=($(basename $i))
	done
}

function rm_atf_links () {
	for i in ${ATF_FILES[@]}; do
		echo $i
		rm $i
	done
}

set_atf_links

${QEMU_BIN_AARCH64} \
	-nographic -machine virt,secure=on -cpu cortex-a57 \
    -kernel ${LINUX64}/${LINUX64_BIN} \
    -append "console=ttyAMA0,38400 keep_bootcon" \
    -initrd ${BUILDROOT}/${BUILDROOT_IMG} -smp 2 -m 1024 -bios bl1.bin \
    -d unimp -semihosting-config enable,target=native

rm_atf_links

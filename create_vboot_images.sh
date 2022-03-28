#!/bin/bash

set -ex

ROOT_DIR=`pwd`
UBOOT=${ROOT_DIR}/u-boot
UBOOT_BIN=build/u-boot
UBOOT_DTB=build/arch/arm/dts/vexpress-v2p-ca9.dtb
UBOOT_DTB_PKEY=vexpress-v2p-ca9-pubkey.dtb
KERNEL_DIR=/home/cpey/dev/src/linux
KERNEL_BIN=arch/arm/boot/zImage
KERNEL_DTB=arch/arm/boot/dts/vexpress-v2p-ca9.dtb
VBOOT=${ROOT_DIR}/verified-boot
OUT_DIR=out2
MKIMAGE_BIN=`pwd`/u-boot/build/tools/mkimage

function get_empty_dtb () 
{
	local out=$1
	cat > ${out}/test.dts <<-__EOF__
	/dts-v1/;

	/ {
		signature {
		};	
	};
	__EOF__
	### Report bug u-boot mkimage
	dtc -I dts -O dtb -o ${out}/ecdsa_public_key.dtb ${out}/test.dts
	echo ${out}/ecdsa_public_key.dtb
}

ALGO=rsa
EMPTY_DTB=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-a|--algorithm)
			ALGO=$2
			shift
			shift
			;;
		-e|--empty-dtb)
			EMPTY_DTB=1
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

if [[ ${ALGO} == "rsa" ]]; then
	ITS_FILE=sign.rsa.its
elif [[ ${ALGO} == "ecdsa" ]]; then
	ITS_FILE=sign.ecdsa.its
else
	echo "Algorithm '"${ALGO}"' not supported"
	exit 1
fi

[[ -d ${VBOOT}/keys ]] && rm -r ${VBOOT}/keys
cp -r keys_${ALGO} ${VBOOT}/keys

pushd `pwd`
cd ${VBOOT}

[[ -d ${OUT_DIR} ]] && rm -r ${OUT_DIR}
mkdir ${OUT_DIR}

cp ${VBOOT}/${ITS_FILE} ${OUT_DIR}
cp -r keys ${OUT_DIR}

ln -s ${KERNEL_DIR}/${KERNEL_DTB} ${OUT_DIR}
ln -s ${KERNEL_DIR}/${KERNEL_BIN} ${OUT_DIR}/Image
ln -s ${UBOOT}/${UBOOT_BIN} ${OUT_DIR}
cp ${UBOOT}/${UBOOT_DTB} ${OUT_DIR}/${UBOOT_DTB_PKEY}
lzop ${OUT_DIR}/Image -o ${OUT_DIR}/Image.lzo

if [[ ${EMPTY_DTB} -eq 0 ]]; then
	${MKIMAGE_BIN} -f ${OUT_DIR}/${ITS_FILE} -K ${OUT_DIR}/${UBOOT_DTB_PKEY} -k ${OUT_DIR}/keys -r ${OUT_DIR}/image.fit
else
	dtb_file=$(get_empty_dtb ${OUT_DIR})
	${MKIMAGE_BIN} -f ${OUT_DIR}/${ITS_FILE} -K ${dtb_file} -k ${OUT_DIR}/keys -r ${OUT_DIR}/image.fit
fi

rm -r keys
popd

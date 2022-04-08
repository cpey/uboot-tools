#!/bin/bash

set -ex

source config.sh

function get_empty_dtb () 
{
	local out=$1
	local dtb=$2
	cat > ${out}/test.dts <<-__EOF__
	/dts-v1/;

	/ {
		signature {
		};
	};
	__EOF__
	### Report bug u-boot mkimage
	dtc -I dts -O dtb -o ${out}/${dtb} ${out}/test.dts
	echo ${out}/${dtb}
}

ALGO=rsa
CURVE=secp256k1
EMPTY_DTB=0
while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-a|--algorithm)
            ALGO=$(echo $2|tr '[:upper:]' '[:lower:]')
			shift
			shift
			;;
		-c|--curve)
			CURVE=$2
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
	DTB_FILE=${RSA_PKEY_DTB}
	dirname=${ALGO}
elif [[ ${ALGO} == "ecdsa" ]]; then
	ITS_FILE=sign.ecdsa.its
	DTB_FILE=${ECDSA_PKEY_DTB}
	dirname=${ALGO}_${CURVE}
else
	echo "Algorithm '"${ALGO}"' not supported"
	exit 1
fi

[[ -d ${VBOOT_OUT} ]] && rm -r ${VBOOT_OUT}
mkdir ${VBOOT_OUT}

[[ -d ${VBOOT_OUT}/keys ]] && rm -r ${VBOOT_OUT}/keys
cp -r ${OUT_DIR}/keys_${dirname} ${VBOOT_OUT}/keys

cp ${VBOOT}/${ITS_FILE} ${VBOOT_OUT}

ln -s ${LINUX}/${LINUX_DTB} ${VBOOT_OUT}
ln -s ${LINUX}/${LINUX_BIN} ${VBOOT_OUT}/Image
ln -s ${UBOOT}/${UBOOT_BIN} ${VBOOT_OUT}
cp ${UBOOT}/${UBOOT_DTB} ${VBOOT_OUT}/${VBOOT_UBOOT_DTB_PKEY}
lzop ${VBOOT_OUT}/Image -o ${VBOOT_OUT}/Image.lzo

if [[ ${EMPTY_DTB} -eq 0 ]]; then
	${MKIMAGE_BIN} -f ${VBOOT_OUT}/${ITS_FILE} -K ${VBOOT_OUT}/${VBOOT_UBOOT_DTB_PKEY} -k ${VBOOT_OUT}/keys -r ${VBOOT_OUT}/image.fit
else
	dtb_file=$(get_empty_dtb ${VBOOT_OUT} ${DTB_FILE})
	${MKIMAGE_BIN} -f ${VBOOT_OUT}/${ITS_FILE} -K ${dtb_file} -k ${VBOOT_OUT}/keys -r ${VBOOT_OUT}/image.fit
fi

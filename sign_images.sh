#!/bin/bash

# Sign Linux kernel image using PKCS#1 v1.5 padding

set -ex

source config.sh

ALGO=rsa
DIGEST=sha256
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--algorithm)
            ALGO=$2
            shift
            shift
            ;;
        -d|--digest)
            DIGEST=$2
            shift
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

[[ ! -d ${OUT_DIR} ]] && mkdir ${OUT_DIR}

if [[ ${ALGO} == "rsa" ]]; then
    priv_key=${ROOT_DIR}/keys_rsa/dev.key
elif [[ ${ALGO} == "ecdsa" ]]; then
    priv_key=${ROOT_DIR}/keys_ecdsa/ec-secp256k1-priv-key.pem
else
    echo "Algorithm '"${ALGO}"' not supported"
    exit -1
fi

openssl dgst -${DIGEST} -binary -out ${OUT_DIR}/uImage.${DIGEST}.digest ${KERNEL_IMG}
openssl pkeyutl -sign -in ${OUT_DIR}/uImage.${DIGEST}.digest -inkey ${priv_key} -pkeyopt digest:${DIGEST} -out ${OUT_DIR}/uImage.sign.${DIGEST}.${ALGO}.pkcs1_5

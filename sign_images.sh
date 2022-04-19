#!/bin/bash

# Sign Linux kernel image using PKCS#1 v1.5 padding

set -ex

source config.sh

ALGO=rsa
DIGEST=sha256
IMAGE=${KERNEL_IMG}
CURVE=secp256k1
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--algorithm)
            ALGO=$2
            shift
            shift
            ;;
        -c|--curve)
            CURVE=$2
            shift
            shift
            ;;
        -d|--digest)
            DIGEST=$2
            shift
            shift
            ;;
        -i|--image)
            IMAGE=$2
            shift
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

function create_dir () {
    local out
    local algo=$1

    [[ ! -d ${SIGN_DIR} ]] && mkdir ${SIGN_DIR}
    out=${SIGN_DIR}/sign_${algo}
    [[ -d ${out} ]] && rm -r ${out}
    mkdir -p ${out}
    echo ${out}
}

[[ ! -d ${OUT_DIR} ]] && mkdir ${OUT_DIR}

if [[ ${ALGO} == "rsa" ]]; then
    priv_key=${OUT_DIR}/keys_rsa/dev.key
elif [[ ${ALGO} == "ecdsa" ]]; then
    priv_key=${OUT_DIR}/keys_ecdsa_${CURVE}/ec-${CURVE}-priv-key.pem
else
    echo "Algorithm '"${ALGO}"' not supported"
    exit -1
fi

if [[ ${ALGO} == "rsa" ]]; then
        out=$(create_dir ${ALGO})
elif [[ ${ALGO} == "ecdsa" ]]; then
        out=$(create_dir ${ALGO}_${CURVE})
fi

out_file=$(basename ${IMAGE}).${DIGEST}
openssl dgst -${DIGEST} -binary -out ${out}/${out_file}.digest ${IMAGE}
openssl pkeyutl -sign \
        -in ${out}/${out_file}.digest \
        -inkey ${priv_key} \
        -pkeyopt digest:${DIGEST} \
        -out ${out}/${out_file}.${ALGO}.pkcs1_5

# Verification
#openssl pkeyutl -in rootfs.img.sha384.digest -inkey ../keys_ecdsa/ec-secp256k1-pub-key.der -keyform DER -pubin -verify -sigfile rootfs.img.sha384.ecdsa.pkcs1_5
#openssl pkeyutl -in test.img.sha384.digest -inkey ../keys_ecdsa/ec-secp256k1-pub-key.der -keyform DER -pubin -verify -sigfile test.img.sha384.ecdsa.pkcs1_5

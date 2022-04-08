#!/bin/bash

set -ex

source config.sh

ALGO=rsa
CURVE=secp256k1
while [[ $# -gt 0 ]]; do
    echo "IN"
    key="$1"
    case $key in
        -a|--algorithm)
            ALGO=$(echo $2|tr '[:upper:]' '[:lower:]')
            shift
            shift
            ;;
        -c|curve)
            CURVE=$2
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

    out=${OUT_DIR}/keys_${algo}
    [[ -d ${out} ]] && rm -r ${out}
    mkdir -p ${out}
    echo ${out}
}

function check_curve() {
    local curve=$1
    existing_curves=$(openssl ecparam -list_curves | tr -d ' ' |
                        sed '/\t/d' | cut -d: -f1 | grep ${curve} | wc -l)
    if [[ ! ${existing_curves} -eq 1 ]]; then
        echo "Unsupported curve type '"${curve}"'"
        exit -1
    fi
}

function create_rsa_keys () {
    local out=$1
    # Create a new public/private key pair and certificate for the public key
    openssl genrsa -F4 -out ${out}/dev.key 2048
    openssl rsa -in ${out}/dev.key -pubout -outform der -out ${out}/pubkey.der
    dd if=${out}/pubkey.der of=${out}/pubkey.raw bs=24 skip=1
    openssl req -batch -new -x509 -key ${out}/dev.key -out ${out}/dev.crt
    
    # Print out
    openssl rsa -in ${out}/dev.key -pubout
    openssl x509 -in ${out}/dev.crt -noout -text
}

function create_ecdsa_keys () {
    local out=$1
    openssl ecparam -name ${CURVE} -genkey -noout -out ${out}/ec-${CURVE}-priv-key.pem
    openssl ec -in ${out}/ec-${CURVE}-priv-key.pem -pubout -outform der -out ${out}/ec-${CURVE}-pub-key.der
    openssl ec -in ${out}/ec-${CURVE}-priv-key.pem -pubout -outform pem -out ${out}/ec-${CURVE}-pub-key.pem
    dd if=${out}/ec-${CURVE}-pub-key.der of=${out}/ec-${CURVE}-pub-key.raw bs=24 skip=1
    openssl req -batch -new -x509 -key ${out}/ec-${CURVE}-priv-key.pem -out ${out}/dev.crt

    # Print out
    openssl ec -in ${out}/ec-${CURVE}-priv-key.pem -pubout
    openssl x509 -in ${out}/dev.crt -noout -text
}

if [[ ${ALGO} == "rsa" ]]; then
        out=$(create_dir ${ALGO})
        create_rsa_keys ${out}
elif [[ ${ALGO} == "ecdsa" ]]; then
        check_curve ${CURVE}
        out=$(create_dir ${ALGO}_${CURVE})
        create_ecdsa_keys ${out}
fi

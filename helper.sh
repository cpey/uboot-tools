#!/bin/bash

source config.sh

function checkout_source ()
{
    local path=$1
    local tag=$2

    pushd
    cd ${path}
    git checkout ${tag}
    popd
}

function get_qemu_bin ()
{
    local arch=$1
    local bin

    if [[ ${arch} == "arm" ]]; then
        bin=QEMU_BIN_ARM
    elif [[ ${arch} == "aarch64" ]]; then
        bin=QEMU_BIN_AARCH64
    else
        echo "Unsupported architecture ${arch}"
        exit -1
    fi
    echo ${bin}
}

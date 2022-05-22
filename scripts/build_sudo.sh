#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--clean)
            CLEAN_BUILD=1
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

pushd `pwd`
cd ${SUDO}

if [[ -n ${CLEAN_BUILD} ]]; then
    [[ -d ${SUDO_INST_DIR} ]] && sudo rm -r ${SUDO_INST_DIR}
fi
[[ ! -d ${SUDO_INST_DIR} ]] && mkdir ${SUDO_INST_DIR}
cd ${SUDO_INST_DIR}

if [[ -n ${CLEAN_BUILD} ]]; then
    ../configure --prefix=${SUDO_INST_DIR}/install
fi

make
sudo make install

popd

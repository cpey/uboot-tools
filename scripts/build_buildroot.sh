#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh
source ${dir}/helper.sh

pushd `pwd`
cd ${BUILDROOT}
checkout_source ${BUILDROOT} ${BUILDROOT_TAG}

make qemu_aarch64_virt_defconfig
utils/config -e BR2_TARGET_ROOTFS_CPIO
utils/config -e BR2_TARGET_ROOTFS_CPIO_GZIP
make olddefconfig
make

popd

#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-c|--clean-build)
			CLEAN_BUILD=1
			shift
			;;
		-s|--save-temps)
			SAVE_TEMPS=1
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

pushd `pwd`
cd ${QEMU}

flags=""
if [[ -n ${SAVE_TEMPS} ]]; then
	flags="-save-temps"
fi

if [[ -n ${CLEAN_BUILD} ]]; then
	rm -rf build
fi

[[ ! -d build ]] && mkdir build
cd build

if [[ -n ${CLEAN_BUILD} || -n ${SAVE_TEMPS} ]]; then
	../configure --extra-cflags=${flags}
fi

make -j`nproc`

popd

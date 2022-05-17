#!/bin/bash

set -ex

dir=$(dirname $0)
source ${dir}/config.sh

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
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

[[ -d build ]] && rm -r build
mkdir build && cd build

flags=""
if [[ -n ${SAVE_TEMPS} ]]; then
	flags="-save-temps"
fi
../configure --extra-cflags=${flags}
make -j`nproc`

popd

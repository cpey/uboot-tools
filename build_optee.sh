#!/bin/bash

set -ex

source config.sh

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-c|--client)
			CLIENT=1
			shift
			;;
		-e|--examples)
			EXAMPLES=1
			shift
			;;
		-f|--full-build)
			FULL=1
			shift
			;;
		-o|--os)
			OS=1
			shift
			;;
		*)
			echo "Invalid argument"
			exit 1
			;;
	esac
done

pushd $(pwd)
cd ${OPTEE}/build

export CROSS_COMPILE=${CC64}
export AARCH64_CROSS_COMPILE=${CC64}

if [[ -n ${CLIENT} ]]; then
	cd ${OPTEE_CLIENT}
	cmake -DCMAKE_INSTALL_PREFIX=${OPTEE_CLIENT}/build \
	      -DCMAKE_C_COMPILER=${CC64}gcc
	make
	make install
fi

if [[ -n ${OS} ]]; then
	cd ${OPTEE_OS}
	make \
		CFG_ARM64_core=y \
		CFG_TEE_BENCHMARK=n \
		CFG_TEE_CORE_LOG_LEVEL=3 \
		CROSS_COMPILE=${CC64} \
		CROSS_COMPILE_core=${CC64} \
		CROSS_COMPILE_ta_arm32=${CC} \
		CROSS_COMPILE_ta_arm64=${CC64} \
		DEBUG=1 \
		O=build \
		PLATFORM=vexpress-qemu_armv8a
fi

if [[ -n ${EXAMPLES} ]]; then
	cd ${OPTEE_EXAMPLES}/hello_world
	cmake -DCMAKE_INSTALL_PREFIX=${OPTEE_EXAMPLES}/hello_world \
	      -DCMAKE_C_COMPILER=${CC64}gcc
	make
	make install

	cd ${OPTEE_EXAMPLES}/hello_world/ta
	make CROSS_COMPILE=${CC} \
		PLATFORM=vexpress-qemu_virt \
		TA_DEV_KIT_DIR=${OPTEE_OS}/build/export-ta_arm32 \
fi

if [[ -n ${FULL} ]]; then
	make toolchains
	make -j$(nproc)
fi

popd

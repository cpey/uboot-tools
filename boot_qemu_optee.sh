#!/bin/bash
set -ex

source config.sh

pushd $(pwd)
cd ${OPTEE}/build

make run-only

popd

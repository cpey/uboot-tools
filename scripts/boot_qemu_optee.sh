#!/bin/bash
set -ex

dir=$(dirname $0)
source ${dir}/config.sh

pushd $(pwd)
cd ${OPTEE}/build

nc -z 127.0.0.1 54320 || gnome-terminal --window -x ${OPTEE}/build/soc_term.py 54320
nc -z 127.0.0.1 54321 || gnome-terminal --window -x ${OPTEE}/build/soc_term.py 54321
make run-only

popd

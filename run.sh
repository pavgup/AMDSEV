#!/bin/bash

set -ex

docker build -t amdsev-build:default docker/
docker build --build-arg UBUNTU_VERSION=22.04 -t amdsev-build:22.04 docker/

run() {
  docker run --init --rm -v $PWD/.ccache:/root/.ccache -v $PWD:$PWD -w $PWD amdsev-build:default "$@"
}
run2204() {
  docker run --init --rm -v $PWD/.ccache:/root/.ccache -v $PWD:$PWD -w $PWD amdsev-build:22.04 "$@"
}

run2204 ./build.sh qemu
run2204 ./build.sh ovmf
run ./build.sh --package kernel guest

run2204 ./repack.sh

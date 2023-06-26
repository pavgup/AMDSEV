#!/bin/bash

set -ex

docker build -t amdsev-build:default docker/

run() {
  docker run --init --rm -v $PWD/.ccache:/root/.ccache -v $PWD:$PWD -w $PWD amdsev-build:default "$@"
}
run ./build.sh --package kernel host

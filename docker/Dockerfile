ARG UBUNTU_VERSION=20.04
FROM ubuntu:${UBUNTU_VERSION}

RUN sed -ie 's/# deb-src/deb-src/' /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
  apt-get install -y git make build-essential ccache gcc g++ python-is-python3 ninja-build flex bison libssl-dev libelf-dev && \
  apt-get build-dep -y qemu-system && \
  apt-get build-dep -y ovmf

RUN apt-get update && apt-get install -y devscripts cpio zstd rsync kmod dracut vim python3-venv

ENV PATH="/usr/lib/ccache:$PATH"
ENV CCACHE_COMPRESS=true

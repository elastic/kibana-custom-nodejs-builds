#!/usr/bin/env bash

set -e
set -x

release_url_base="$1"
full_version="$2"
config_flags=${3:-""}

if [[ $(arch) == x86_64 ]]; then
  architecture="x64";
else
  architecture="arm64"
fi

ls -la  "/home/node/workdir/src"
ls -la  "/home/node/workdir/src/node-${full_version}"

# See https://github.com/nodejs/unofficial-builds/commit/6853f5477ca0b8bce8d141e9b8670f7ad679cac2
cd "/home/node/workdir/src/node-${full_version}"/deps/cares/config/linux
sed -i 's/define HAVE_SYS_RANDOM_H 1/undef HAVE_SYS_RANDOM_H/g' ./ares_config.h
sed -i 's/define HAVE_GETRANDOM 1/undef HAVE_GETRANDOM/g' ./ares_config.h

cd "/home/node/workdir/src/node-${full_version}"

# Compile from source
export CCACHE_DIR="/home/node/workdir/.ccache-${architecture}"
export CC="ccache gcc"
export CXX="ccache g++"

. /opt/rh/devtoolset-10/enable
. /opt/rh/rh-python38/enable

make -j"$(getconf _NPROCESSORS_ONLN)" binary V= \
  DESTCPU="$architecture" \
  ARCH="$architecture" \
  DISTTYPE="release" \
  RELEASE_URLBASE="$release_url_base" \
  CONFIG_FLAGS="$config_flags"

mkdir -p /home/node/workdir/dist/
chmod a+w /home/node/workdir/dist
mv node-*.tar.?z /home/node/workdir/dist/
chmod a+rwx /home/node/workdir/dist/*

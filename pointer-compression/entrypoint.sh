#!/usr/bin/env bash

set -e
set -x

release_url_base="$1"
full_version="$2"
config_flags='--experimental-enable-pointer-compression'

if [[ $(arch) == x86_64 ]]; then
  architecture="x64";
else
  architecture="arm64"
fi

ls -la  "/home/node/workdir/src"
ls -la  "/home/node/workdir/src/node-${full_version}"

cd "/home/node/workdir/src/node-${full_version}"

# Fix GetReadOnlyRoots() missing no-argument overload with pointer compression in Node 22
# ../deps/v8/src/ast/ast-value-factory.cc:86:65: error: no matching function for call to 'v8::internal::ReadOnlyHeap::GetReadOnlyRoots() const'
major_version=$(echo "$full_version" | cut -d. -f1 | sed 's/^v//')
if [[ "$major_version" -eq 22 ]]; then
  sed -i 's/StringHasher::DecodeArrayIndexFromHashField(/Name::ArrayIndexValueBits::decode(/' deps/v8/src/ast/ast-value-factory.cc
  sed -i 's/, HashSeed(ReadOnlyHeap::GetReadOnlyRoots()))/)/g' deps/v8/src/ast/ast-value-factory.cc
fi

# Compile from source
export CCACHE_DIR="/home/node/workdir/.ccache-${architecture}"
export CC="ccache gcc-13"
export CXX="ccache g++-13"

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

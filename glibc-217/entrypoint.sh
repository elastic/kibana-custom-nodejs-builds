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

# Polyfill memfd_create only for Node.js >= 24 (syscall numbers: x64=319, arm64=279)
# ../deps/v8/src/wasm/wasm-objects.cc: In static member function 'static v8::internal::MaybeDirectHandle<v8::internal::WasmMemoryMapDescriptor> v8::internal::WasmMemoryMapDescriptor::NewFromAnonymous(v8::internal::Isolate*, size_t)':
# ../deps/v8/src/wasm/wasm-objects.cc:1338:68: error: 'MFD_CLOEXEC' was not declared in this scope
#  1338 |   int file_descriptor = memfd_create("wasm_memory_map_descriptor", MFD_CLOEXEC);
#       |                                                                    ^~~~~~~~~~~
# ../deps/v8/src/wasm/wasm-objects.cc:1338:25: error: 'memfd_create' was not declared in this scope; did you mean 'timer_create'?
#  1338 |   int file_descriptor = memfd_create("wasm_memory_map_descriptor", MFD_CLOEXEC);
#       |                         ^~~~~~~~~~~~
#       |                         timer_create
# make[2]: *** [tools/v8_gypfiles/v8_base_without_compiler.target.mk:1144: /home/node/workdir/src/node-v24.12.0/out/Release/obj.target/v8_base_without_compiler/deps/v8/src/wasm/wasm-objects.o] Error 1
major_version=$(echo "$full_version" | cut -d. -f1 | sed 's/^v//')
if [[ "$major_version" -ge 24 ]]; then
  if [[ "$architecture" == "x64" ]]; then sc=319; else sc=279; fi
  cat > memfd_polyfill.h <<EOF
#include <sys/syscall.h>
#include <unistd.h>

#ifndef MFD_CLOEXEC
#define MFD_CLOEXEC 0x0001U
#endif

static inline int memfd_create(const char *name, unsigned int flags) {
    return syscall($sc, name, flags);
}
EOF
  sed -i "/#include \"src\/wasm\/wasm-objects.h\"/r memfd_polyfill.h" deps/v8/src/wasm/wasm-objects.cc
  rm memfd_polyfill.h
fi

# Compile from source
export CCACHE_DIR="/home/node/workdir/.ccache-${architecture}"
export CC="ccache /usr/local/gcc-12/bin/gcc"
export CXX="ccache /usr/local/gcc-12/bin/g++"
export LD_LIBRARY_PATH="/usr/local/gcc-12/lib64"
export LDFLAGS="-static-libstdc++ -static-libgcc"

# For loading a newer version of binutils
. /opt/rh/devtoolset-10/enable

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

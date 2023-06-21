#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env
# ARCH provided in env
assert_correct_arch $ARCH

BUILD_IMAGE_NAME=$(get_build_image_name)
RE2_FULL_VERSION=${RE2_VERSION:-1.17.7} # $1
NODE_FULL_VERSION="v$TARGET_VERSION" # $2
NODE_DOWNLOAD_BASE_URL="https://storage.cloud.google.com/kibana-custom-node-artifacts/node-glibc-217/dist/v$TARGET_VERSION/"
TARGET_PLATFORM="linux/$ARCH"

echo "--- Building RE2 for $TARGET_PLATFORM"
mkdir -p ./workdir_re2/
chmod -R a+rwx ./workdir_re2/
docker run --rm -it --platform $TARGET_PLATFORM --entrypoint /home/node/re2_entrypoint.sh \
  -v ./workdir_re2:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RE2_FULL_VERSION \
  $NODE_FULL_VERSION \
  $NODE_DOWNLOAD_BASE_URL

#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env
# TARGET_ARCH provided in env
assert_correct_arch $TARGET_ARCH

TARGET_NODE_VERSION="v$TARGET_VERSION"
BUILD_IMAGE_NAME=$(get_build_image_name)
TARGET_PLATFORM="linux/$TARGET_ARCH"
RELEASE_URL_BASE="https://unofficial-builds.nodejs.org/download/release/"

echo "Running node.js build in folder: `pwd`"

echo '--- Downloading node source'
FILE_NAME="node-$TARGET_NODE_VERSION.tar.xz"
OUTPUT_PATH="./workdir/src/$FILE_NAME"
retry 5 15 curl --create-dirs --output $OUTPUT_PATH -fsSLO --compressed \
  https://nodejs.org/download/release/$TARGET_NODE_VERSION/$FILE_NAME
tar -xf $OUTPUT_PATH -C ./workdir/src
chmod -R a+rwx ./workdir/


echo "--- Buidling node for $TARGET_PLATFORM"
docker run --rm -it --platform $TARGET_PLATFORM \
  -v ./workdir:/home/node/workdir:Z \
  $BUILD_IMAGE_NAME \
  $RELEASE_URL_BASE \
  $TARGET_NODE_VERSION

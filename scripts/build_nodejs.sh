#!/bin/bash
set -euo pipefail

TARGET_VERSION="18.15.0"
TARGET_NODE_VERSION="v$TARGET_VERSION"
RELEASE_URL_BASE="https://unofficial-builds.nodejs.org/download/release/"

if [[ "$ARCH" == "arm64" || "$ARCH" == "amd64" ]]; then
  # we're good, supported architecture
  echo "Building for architecture: $ARCH"
else
  echo "ARCH (=$ARCH) env variable is not one of: arm64, amd64"
  exit 1
fi

BUILD_IMAGE_NAME="docker.elastic.co/elastic/nodejs-custom:$TARGET_VERSION-$ARCH"

echo '--- Downloading node source'
curl --create-dirs --output-dir ./workdir/src -fsSLO --compressed \
  https://nodejs.org/download/release/$TARGET_NODE_VERSION/node-$TARGET_NODE_VERSION.tar.xz
tar -xf ./workdir/src/node-$TARGET_NODE_VERSION.tar.xz -C ./workdir/src
chmod -R a+rwx ./workdir/


if [[ "$ARCH" == "arm64" ]]; then
  echo '--- Buidling node for linux/arm64'
  docker run --rm -it --platform linux/arm64 \
    -v ./workdir:/home/node/workdir:Z \
    $BUILD_IMAGE_NAME \
    $RELEASE_URL_BASE \
    $TARGET_NODE_VERSION
elif [[  "$ARCH" == "amd64" ]]; then
  echo '--- Buidling node for linux/amd64'
  docker run --rm -it --platform linux/amd64 \
    -v ./workdir:/home/node/workdir:Z \
    $BUILD_IMAGE_NAME \
    $RELEASE_URL_BASE \
    $TARGET_NODE_VERSION
fi

#!/bin/bash
set -euo pipefail

TARGET_NODE_VERSION="v18.15.0"
RELEASE_URL_BASE="https://unofficial-builds.nodejs.org/download/release/"
BUILD_IMAGE_NAME=nodejs-custom:18.15.0

echo '--- Downloading node source'
curl --create-dirs --output-dir ./workdir/src -fsSLO --compressed \
  https://nodejs.org/download/release/$TARGET_NODE_VERSION/node-$TARGET_NODE_VERSION.tar.xz
tar -xf ./workdir/src/node-$TARGET_NODE_VERSION.tar.xz -C ./workdir/src


echo '--- Buidling node for linux/amd64'
docker run --rm -it --platform linux/amd64 \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RELEASE_URL_BASE \
  $FULL_VERSION

echo '--- Buidling node for linux/arm64'
docker run --rm -it --platform linux/arm64 \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RELEASE_URL_BASE \
  $FULL_VERSION

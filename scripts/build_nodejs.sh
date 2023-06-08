#!/bin/bash
set -euo pipefail

TARGET_VERSION="18.15.0"
TARGET_NODE_VERSION="v$TARGET_VERSION"
RELEASE_URL_BASE="https://unofficial-builds.nodejs.org/download/release/"
BUILD_IMAGE_NAME="docker.io/elastic/nodejs-custom:$TARGET_VERSION"

echo '--- Downloading node source'
curl --create-dirs --output-dir ./workdir/src -fsSLO --compressed \
  https://nodejs.org/download/release/$TARGET_NODE_VERSION/node-$TARGET_NODE_VERSION.tar.xz
tar -xf ./workdir/src/node-$TARGET_NODE_VERSION.tar.xz -C ./workdir/src


echo '--- Buidling node for linux/amd64'
docker run --rm -it --platform linux/amd64 \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RELEASE_URL_BASE \
  $TARGET_NODE_VERSION

echo '--- Buidling node for linux/arm64'
docker run --rm -it --platform linux/arm64 \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RELEASE_URL_BASE \
  $TARGET_NODE_VERSION

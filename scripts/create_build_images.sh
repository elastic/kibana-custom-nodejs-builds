#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(dirname $0)
DOCKER_BUILD_CONTEXT_DIR="$SCRIPT_DIR/../build-image-config/"
TARGET_VERSION="18.15.0"

if [[ "$ARCH" == "arm64" || "$ARCH" == "amd64" ]]; then
  # we're good, supported architecture
  echo "Building for architecture: $ARCH"
else
  echo "ARCH (=$ARCH) env variable is not one of: arm64, amd64"
  exit 1
fi

TARGET_PLATFORM="linux/$ARCH"
IMAGE_NAME="docker.elastic.co/elastic/nodejs-custom:$TARGET_VERSION-$ARCH"

echo "--- Creating multiarch driver"
if [[ $(docker buildx ls | grep multiarch | wc -l) -lt 1 ]]; then
  docker buildx create --name multiarch --driver docker-container --use
fi


if [[ "$ARCH" == "arm64" ]]; then
  echo "--- Building node.js build images (arm64)"
  DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
    --platform $TARGET_PLATFORM \
    --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
    --load \
    --tag $IMAGE_NAME \
    $DOCKER_BUILD_CONTEXT_DIR
elif [[ "$ARCH" == "amd64" ]]; then
  echo "--- Building node.js build images (amd64)"
  DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
    --platform $TARGET_PLATFORM \
    --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
    --load \
    --tag $IMAGE_NAME \
    $DOCKER_BUILD_CONTEXT_DIR
fi

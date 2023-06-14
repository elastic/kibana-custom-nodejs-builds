#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env
# ARCH provided in env
assert_correct_arch $ARCH

TARGET_PLATFORM="linux/$ARCH"
IMAGE_NAME="docker.elastic.co/elastic/nodejs-custom:$TARGET_VERSION-$ARCH"
SCRIPT_DIR=$(dirname $0)
DOCKER_BUILD_CONTEXT_DIR="$SCRIPT_DIR/../build-image-config/"


echo "--- Creating multiarch driver"
if [[ $(docker buildx ls | grep multiarch | wc -l) -lt 1 ]]; then
  docker buildx create --name multiarch --driver docker-container --use
fi


echo "--- Building node.js build image ($ARCH)"
DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
  --platform $TARGET_PLATFORM \
  --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
  --load \
  --tag $IMAGE_NAME \
  $DOCKER_BUILD_CONTEXT_DIR

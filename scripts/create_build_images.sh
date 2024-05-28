#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env
# TARGET_ARCH provided in env
assert_correct_arch $TARGET_ARCH

TARGET_PLATFORM="linux/$TARGET_ARCH"
IMAGE_NAME=$(get_build_image_name)
SCRIPT_DIR=$(dirname $0)
DOCKER_BUILD_CONTEXT_DIR="$SCRIPT_DIR/../$TARGET_VARIANT/"


echo "--- Creating multiarch driver"
if [[ $(docker buildx ls | grep multiarch | wc -l) -lt 1 ]]; then
  docker buildx create --name multiarch --driver docker-container --use
fi


echo "--- Building node.js build image ($TARGET_ARCH)"
DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
  --platform $TARGET_PLATFORM \
  --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
  --load \
  --tag $IMAGE_NAME \
  $DOCKER_BUILD_CONTEXT_DIR

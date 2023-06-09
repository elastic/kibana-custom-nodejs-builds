#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(dirname $0)
DOCKER_BUILD_CONTEXT_DIR="$SCRIPT_DIR/../build-image-config/"
TARGET_VERSION="18.15.0"
IMAGE_NAME="docker.io/elastic/nodejs-custom:$TARGET_VERSION"

# echo "--- Starting qemu image"
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --userns host

echo "--- Creating multiarch driver"
if [[ $(docker buildx ls | grep multiarch | wc -l) -lt 1 ]]; then
  docker buildx create --name multiarch --driver docker-container --use
fi


echo "--- Building node.js build images"
DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
  --platform linux/amd64,linux/arm64 \
  --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
  --tag $IMAGE_NAME --push \
  $DOCKER_BUILD_CONTEXT_DIR
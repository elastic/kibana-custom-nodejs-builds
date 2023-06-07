#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(dirname $0)
DOCKER_BUILD_CONTEXT_DIR="$SCRIPT_DIR/../build-image-config/"

# echo "--- Starting qemu image"
# docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --userns host

echo "--- Creating multiarch driver"
docker buildx create --name multiarch --driver docker-container --use


echo "--- Building node.js build images"
DOCKER_BUILDKIT=1 docker buildx build --progress=plain  \
  --platform linux/amd64,linux/arm64 \
  --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
  --tag nodejs-custom:18.15.0 $DOCKER_BUILD_CONTEXT_DIR

# echo "--- Building node.js build images"
# DOCKER_BUILDKIT=1 docker buildx build --progress=plain --push  \
#   --platform linux/amd64,linux/arm64 \
#   --build-arg GROUP_ID=1000 --build-arg USER_ID=1000 \
#   --tag nodejs-custom:18.15.0 $DOCKER_BUILD_CONTEXT_DIR

# docker pull --platform linux/amd64 nodejs-custom:18.15.0
# docker pull --platform linux/arm64 nodejs-custom:18.15.0

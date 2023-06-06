#!/bin/bash
set -euo pipefail

BUILD_IMAGE_NAME="nodejs-custom:18.15.0"

RE2_FULL_VERSION="1.17.7" # $1
NODE_FULL_VERSION="v18.15.0" # $2
NODE_DOWNLOAD_BASE_URL="https://github.com/azasypkin/kibana/releases/download/nodej-custom" # $3, TODO: adjust based on the publish URLs

docker run --rm -it --platform linux/amd64 --entrypoint /home/node/re2_entrypoint.sh \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RE2_FULL_VERSION \
  $NODE_FULL_VERSION \
  $NODE_DOWNLOAD_BASE_URL

docker run --rm -it --platform linux/arm64 --entrypoint /home/node/re2_entrypoint.sh \
  -v ./workdir:/home/node/workdir \
  $BUILD_IMAGE_NAME \
  $RE2_FULL_VERSION \
  $NODE_FULL_VERSION \
  $NODE_DOWNLOAD_BASE_URL

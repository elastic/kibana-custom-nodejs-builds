#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env

BUCKET_NAME="kibana-custom-node-artifacts"
ARTIFACT_BASE_PATH="node-glibc-217/dist/v$TARGET_VERSION/"
ARTIFACT_DIST_DIR="./workdir/dist"

echo "--- Uploading build artifacts"
gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

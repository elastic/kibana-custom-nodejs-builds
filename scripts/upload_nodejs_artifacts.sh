#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env

ARTIFACT_BASE_PATH="node-glibc-217/dist/v$TARGET_VERSION/"
ARTIFACT_DIST_DIR="./workdir/dist"

list_shasums_in_folder $ARTIFACT_DIST_DIR

echo "--- Uploading build artifacts"
gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

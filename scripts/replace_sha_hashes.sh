#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env

ARTIFACT_BASE_PATH="node-pointer-compression/dist/v$TARGET_VERSION"
SHASUMS_LOCATION="https://nodejs.org/dist/v$TARGET_VERSION/SHASUMS256.txt"

ARTIFACT_DIST_DIR="./workdir/download"

echo "--- Activating service account"
activate_service_account

echo "--- Downloading node.js $TARGET_VERSION glibc-217 artifacts"
mkdir -p $ARTIFACT_DIST_DIR

gsutil cp -r gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH/* "$ARTIFACT_DIST_DIR/"

echo "--- Downloading SHASUMS256.txt"
retry 5 10 curl -fsSLO $SHASUMS_LOCATION
mv SHASUMS256.txt $ARTIFACT_DIST_DIR/SHASUMS256.txt

echo "--- Replacing checksums with local file hashes"
replace_shasums_in_folder $ARTIFACT_DIST_DIR

echo "--- Uploading SHASUMS256.txt to $BUCKET_NAME"
gsutil cp -r "$ARTIFACT_DIST_DIR/SHASUMS256.txt" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH/

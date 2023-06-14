#!/bin/bash
set -euo pipefail

# TARGET_VERSION provided in env

BUCKET_NAME="kibana-custom-node-artifacts"
ARTIFACT_BASE_PATH="node-glibc-217/dist/v$TARGET_VERSION/"
ARTIFACT_DIST_DIR="./workdir/dist"

echo "--- Removing variant tags from file names"
for name in $(ls $ARTIFACT_DIST_DIR | grep tar); do
  NAME_STRIPPED=$(echo "$name" | sed s/-glibc-217//)
  mv $ARTIFACT_DIST_DIR/$name $ARTIFACT_DIST_DIR/$NAME_STRIPPED
done

echo "--- Uploading build artifacts"
gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

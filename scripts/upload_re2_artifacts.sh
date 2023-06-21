#!/bin/bash
set -euo pipefail

BUCKET_NAME="kibana-custom-node-artifacts"
RE2_FULL_VERSION=${RE2_VERSION:-1.17.7} # $1
ARTIFACT_BASE_PATH="re2-glibc-217/v$RE2_FULL_VERSION/"
ARTIFACT_DIST_DIR="./workdir_re2/dist"

# echo "--- Removing variant tags from file names"
# for name in $(ls $ARTIFACT_DIST_DIR | grep tar); do
#   NAME_STRIPPED=$(echo "$name" | sed s/-glibc-217//)
#   mv $ARTIFACT_DIST_DIR/$name $ARTIFACT_DIST_DIR/$NAME_STRIPPED
# done

echo "--- Uploading build artifacts"
gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

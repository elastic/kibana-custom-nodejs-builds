#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

# TARGET_VERSION provided in env

BUCKET_NAME="kibana-custom-node-artifacts"
ARTIFACT_BASE_PATH="node-glibc-217/dist/v$TARGET_VERSION/"
ARTIFACT_DIST_DIR="./workdir/dist"
SHASUMS_LOCATION="https://nodejs.org/dist/v$TARGET_VERSION/SHASUMS256.txt"

# echo "--- Removing variant tags from file names"
# for name in $(ls $ARTIFACT_DIST_DIR | grep tar); do
#   NAME_STRIPPED=$(echo "$name" | sed s/-glibc-217//)
#   mv $ARTIFACT_DIST_DIR/$name $ARTIFACT_DIST_DIR/$NAME_STRIPPED
# done

echo "--- Replacing SHASUMS256.txt entries"
retry 5 10 curl -fsSLO $SHASUMS_LOCATION
mv SHASUMS256.txt ./workdir/SHASUMS256.txt
replace_shasums_in_folder ./workdir

echo "--- Uploading build artifacts"
gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

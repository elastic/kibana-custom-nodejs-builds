#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

RE2_FULL_VERSION=$RE2_VERSION # $1
ARTIFACT_BASE_PATH="re2-glibc-217/$RE2_FULL_VERSION/"
ARTIFACT_DIST_DIR="./workdir_re2/dist"

list_shasums_in_folder $ARTIFACT_DIST_DIR

echo "--- Uploading build artifacts"
echo "--- Uploading build artifacts"
if [[ "${DRY_RUN:-}" == "1" || "${DRY_RUN:-}" == "true" ]]; then
  echo "Dry run enabled, skipping upload"
  exit 0
else
  gsutil cp -r "$ARTIFACT_DIST_DIR/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH
fi

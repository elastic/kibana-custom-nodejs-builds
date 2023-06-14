#!/bin/bash
set -euox pipefail

# TARGET_VERSION provided in env

BUCKET_NAME="kibana-custom-node-artifacts"
ARTIFACT_BASE_PATH="node-glibc-217/dist/v$TARGET_VERSION/"

echo "--- Uploading build artifacts"
gsutil cp -r "./workdir/dist/*" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

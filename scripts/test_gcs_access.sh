#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

ARTIFACT_BASE_PATH="re2-glibc-217/test/"

echo "POTATO MåN" > test.txt 

gsutil cp -r "test.txt" gs://$BUCKET_NAME/$ARTIFACT_BASE_PATH

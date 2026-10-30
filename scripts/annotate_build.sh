#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

echo "--- Annotating build with build params"
buildkite-agent annotate "node.js@v${TARGET_VERSION} custom builds" \
  --context "node-${TARGET_VERSION}" --style 'info'

#!/bin/bash
set -euo pipefail

source ./scripts/common.sh

echo "--- Annotating build with build params"
buildkite-agent annotate "node.js@v${TARGET_VERSION} & re2@v${RE2_VERSION} with glibc 2.17" --style 'info'

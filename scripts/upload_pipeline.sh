#!/usr/bin/env bash
set -euo pipefail

python3 scripts/generate_pipeline.py | buildkite-agent pipeline upload --no-interpolation

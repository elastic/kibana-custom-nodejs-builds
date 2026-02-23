#!/usr/bin/env bash
set -euo pipefail

default_target_versions=("22.17.1" "24.13.1")
target_versions=()

if [[ -n "${OVERRIDE_TARGET_VERSION:-}" ]]; then
  target_versions=("$OVERRIDE_TARGET_VERSION")
else
  target_versions=("${default_target_versions[@]}")
fi

target_versions_yaml=""
for target_version in "${target_versions[@]}"; do
  target_versions_yaml+="          - \"$target_version\""$'\n'
done

cat <<EOF
steps:
  - label: Annotate build with node version (v{{matrix.target_version}})
    command:
      - scripts/annotate_build.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
    matrix:
      setup:
        target_version:
$target_versions_yaml
  - label: Build custom node.js artifacts with glibc 2.17 for x64 (v{{matrix.target_version}})
    command:
      - scripts/create_build_images.sh
      - scripts/build_nodejs.sh
      - scripts/upload_nodejs_artifacts.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_ARCH: amd64
      TARGET_VARIANT: "glibc-217"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: c2-standard-16
    timeout_in_minutes: 60
    matrix:
      setup:
        target_version:
$target_versions_yaml

  - label: Build custom node.js artifacts with glibc 2.17 for arm64 (v{{matrix.target_version}})
    command:
      - scripts/create_build_images.sh
      - scripts/build_nodejs.sh
      - scripts/upload_nodejs_artifacts.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_ARCH: arm64
      TARGET_VARIANT: "glibc-217"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: c2-standard-60
    timeout_in_minutes: 300
    matrix:
      setup:
        target_version:
$target_versions_yaml

  - label: Build custom node.js artifacts with pointer compression for x64 (v{{matrix.target_version}})
    if: build.env('SKIP_POINTER_COMPRESSION') == null
    command:
      - scripts/create_build_images.sh
      - scripts/build_nodejs.sh
      - scripts/upload_nodejs_artifacts.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_ARCH: amd64
      TARGET_VARIANT: "pointer-compression"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: c2-standard-16
    timeout_in_minutes: 60
    matrix:
      setup:
        target_version:
$target_versions_yaml

  - label: Build custom node.js artifacts with pointer compression for arm64 (v{{matrix.target_version}})
    if: build.env('SKIP_POINTER_COMPRESSION') == null
    command:
      - scripts/create_build_images.sh
      - scripts/build_nodejs.sh
      - scripts/upload_nodejs_artifacts.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_ARCH: arm64
      TARGET_VARIANT: "pointer-compression"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: c2-standard-60
    timeout_in_minutes: 300
    matrix:
      setup:
        target_version:
$target_versions_yaml

  - wait

  - label: Fix SHASUMS256.txt with newly built files' hashes with glibc 2.17 (v{{matrix.target_version}})
    command:
      - scripts/replace_sha_hashes.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_VARIANT: "glibc-217"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: n2-standard-2
    matrix:
      setup:
        target_version:
$target_versions_yaml

  - label: Fix SHASUMS256.txt with newly built files' hashes with pointer compression (v{{matrix.target_version}})
    if: build.env('SKIP_POINTER_COMPRESSION') == null
    command:
      - scripts/replace_sha_hashes.sh
    env:
      TARGET_VERSION: "{{matrix.target_version}}"
      TARGET_VARIANT: "pointer-compression"
    agents:
      image: family/kibana-ubuntu-2404
      provider: gcp
      machineType: n2-standard-2
    matrix:
      setup:
        target_version:
$target_versions_yaml
EOF

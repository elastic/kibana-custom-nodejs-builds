#!/usr/bin/env python3
"""Expand the supported Node versions into Buildkite build and checksum steps."""

import json
import os
import re
import sys


VARIANTS = (
    ("glibc-217", "glibc 2.17", "SKIP_GLIBC_217", 240, 720),
    ("pointer-compression", "pointer compression", "SKIP_POINTER_COMPRESSION", 180, 360),
)
ARCHITECTURES = (
    ("amd64", "x64", "c4-standard-4"),
    ("arm64", "arm64", "c4-standard-16"),
)


def selected_versions():
    override = os.environ.get("OVERRIDE_TARGET_VERSION", "").strip()
    versions = [override] if override else os.environ["SUPPORTED_NODE_VERSIONS"].split()
    if not versions or len(versions) != len(set(versions)):
        raise ValueError("Node version list must be nonempty and contain no duplicates")
    for version in versions:
        if not re.fullmatch(r"[0-9]+\.[0-9]+\.[0-9]+", version):
            raise ValueError(f"Invalid Node version: {version!r}")
    return versions


def build_pipeline(versions):
    steps = []
    for version in versions:
        steps.append(
            {
                "label": f"Annotate Node.js {version}",
                "command": "scripts/annotate_build.sh",
                "env": {"TARGET_VERSION": version},
            }
        )

    for version in versions:
        for variant, description, skip_env, x64_timeout, arm64_timeout in VARIANTS:
            for arch, arch_label, machine_type in ARCHITECTURES:
                steps.append(
                    {
                        "label": f"Build Node.js {version} with {description} for {arch_label}",
                        "if": f"build.env('{skip_env}') == null",
                        "command": [
                            "scripts/create_build_images.sh",
                            "scripts/build_nodejs.sh",
                            "scripts/upload_nodejs_artifacts.sh",
                        ],
                        "env": {
                            "TARGET_VERSION": version,
                            "TARGET_ARCH": arch,
                            "TARGET_VARIANT": variant,
                        },
                        "agents": {
                            "image": "family/kibana-ubuntu-2404",
                            "provider": "gcp",
                            "machineType": machine_type,
                            "diskType": "hyperdisk-balanced",
                            "diskSizeGb": 125,
                        },
                        "timeout_in_minutes": x64_timeout if arch == "amd64" else arm64_timeout,
                    }
                )

    steps.append({"wait": None})

    for version in versions:
        for variant, description, skip_env, _, _ in VARIANTS:
            steps.append(
                {
                    "label": f"Fix Node.js {version} SHASUMS256.txt with {description}",
                    "if": f"build.env('{skip_env}') == null",
                    "command": "scripts/replace_sha_hashes.sh",
                    "env": {"TARGET_VERSION": version, "TARGET_VARIANT": variant},
                    "agents": {
                        "image": "family/kibana-ubuntu-2404",
                        "provider": "gcp",
                        "machineType": "n2-standard-2",
                    },
                }
            )

    return {"steps": steps}


if __name__ == "__main__":
    try:
        json.dump(build_pipeline(selected_versions()), sys.stdout)
        sys.stdout.write("\n")
    except (KeyError, ValueError) as error:
        sys.exit(str(error))

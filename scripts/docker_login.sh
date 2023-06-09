#!/bin/bash

set -euo pipefail

registry_user=$(vault read -field=username secret/ci/elastic-ci-agent-images/docker-registry)
registry_password=$(vault read -field=password secret/ci/elastic-ci-agent-images/docker-registry)

echo -n "Logging in to docker.elastic.co as ${registry_user}... "
docker login --username="${registry_user}" --password="${registry_password}" docker.elastic.co

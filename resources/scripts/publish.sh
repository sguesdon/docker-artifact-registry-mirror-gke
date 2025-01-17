#!/bin/bash

VERSION=$2
REPOSITORY=$1

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

cp README.md "${HELM_DIR}/README.md"
helm package "${HELM_DIR}" --version="${VERSION}"
helm push "docker-artifact-registry-mirror-gke-${VERSION}.tgz" "${REPOSITORY}"

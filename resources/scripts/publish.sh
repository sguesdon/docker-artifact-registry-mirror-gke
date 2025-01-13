#!/bin/bash
VERSION=$2
REPOSITORY=$1
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source "${SCRIPT_DIR}/common.sh"

package_mirror_helm_chart "${VERSION}"
helm push "docker-gcp-private-mirror-${VERSION}.tgz" "${REPOSITORY}"
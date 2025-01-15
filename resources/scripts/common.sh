#!/bin/bash

package_mirror_helm_chart() {
  VERSION=$1

  echo "--- package helm chart"
  cp README.md ./src/README.md
  helm package ./src --version="${VERSION}"
}

lint_mirror_helm_chart() {
  echo "--- lint helm chart"
  helm lint ./src
}

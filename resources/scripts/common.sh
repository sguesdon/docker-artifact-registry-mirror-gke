#!/bin/bash

package_mirror_helm_chart() {
  VERSION=$1

  echo "--- package helm chart"
  helm package ./src --version="${VERSION}"
}

lint_mirror_helm_chart() {
    echo "--- lint helm chart"
    helm lint ./src
}
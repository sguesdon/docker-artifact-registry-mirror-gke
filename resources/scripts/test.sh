#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source "${SCRIPT_DIR}/common.sh"

NAMESPACE=mirror-test

FAKE_REGISTRY_IMAGE_NAME=fake-registry
FAKE_REGISTRY_MANIFEST_FILENAME=./tests/resources/fake-registry-deployment.yaml

MIRROR_RELEASE_NAME=private-gcp-mirror

build_fake_registry_image() {
  DIR=$1
  IMAGE_NAME=$2

  echo "--- Build fake registry, tests image"
  docker build -t "${IMAGE_NAME}" --no-cache "${DIR}"
}

clean_and_deploy_test_helm_chart() {
  RELEASE_NAME=$1
  
  echo "--- Uninstall test helm chart"
  helm uninstall "${RELEASE_NAME}" || echo "Skipping uninstall"
  kubectl wait --timeout=300s --for=delete --all "pod"

  echo "--- Deploy test helm chart"
  helm upgrade --dependency-update --install "$RELEASE_NAME" ./tests/helm-chart
  kubectl wait --timeout=300s --for=condition=available --all "deployment"
}

run_tests_in_fake_registry() {

  echo "--- Running tests in fake registry container"
  POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -l "app=fake-registry")
  kubectl exec -it "pod/${POD_NAME}" -- npm run test
}

configure_env() {

  if [ -n "$MINIKUBE" ]; then
    echo "--- Setup minikube docker env"
    eval $(minikube docker-env)
  fi

  echo "--- Create namespace and set current"
  kubectl create namespace "${NAMESPACE}" || echo "namespace already exist"
  kubectl config set-context --current --namespace="${NAMESPACE}"
}

main() {
  configure_env

  build_fake_registry_image "./tests/fake-registry" "fake-registry"
  clean_and_deploy_test_helm_chart "fake-registry"

  run_tests_in_fake_registry
}

main

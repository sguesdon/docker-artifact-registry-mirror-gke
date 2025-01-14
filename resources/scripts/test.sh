#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source "${SCRIPT_DIR}/common.sh"

NAMESPACE=mirror-test
FAKE_REGISTRY_APP_NAME=fake-registry
FAKE_REGISTRY_IMAGE_NAME=fake-registry
TEST_HELM_CHART_RELEASE_NAME=fake-registry
TEST_HELM_CHART_DIR=./tests/fake-registry

build_fake_registry_image() {
  local DIR=$1
  local IMAGE_NAME=$2

  echo "--- Build fake registry, tests image"
  docker build -t "${IMAGE_NAME}" --no-cache "${DIR}"
}

clean_and_deploy_test_helm_chart() {
  local RELEASE_NAME=$1
  
  echo "--- Uninstall test helm chart"
  helm uninstall "${RELEASE_NAME}" || echo "Skipping uninstall"
  kubectl wait --timeout=300s --for=delete --all "pod"

  echo "--- Deploy test helm chart"
  helm upgrade --dependency-update --install "$RELEASE_NAME" ./tests/helm-chart
  kubectl wait --timeout=300s --for=condition=available --all "deployment"
}

run_tests_in_fake_registry() {
  local APP_SELECTOR=$1

  echo "--- Running tests in fake registry container"
  POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -l "app=${APP_SELECTOR}")
  kubectl exec -it "pod/${POD_NAME}" -- npm run test
}

configure_env() {
  local TARGET_NAMESPACE=$1

  if [ -n "$MINIKUBE" ]; then
    echo "--- Setup minikube docker env"
    eval $(minikube docker-env)
  fi

  echo "--- Create namespace and set current"
  kubectl create namespace "${TARGET_NAMESPACE}" || echo "namespace already exist"
  kubectl config set-context --current --namespace="${TARGET_NAMESPACE}"
}

main() {
  configure_env "${NAMESPACE}"
  build_fake_registry_image "${TEST_HELM_CHART_DIR}" "${FAKE_REGISTRY_IMAGE_NAME}"
  clean_and_deploy_test_helm_chart "${TEST_HELM_CHART_RELEASE_NAME}"
  run_tests_in_fake_registry "${FAKE_REGISTRY_APP_NAME}"
}

main

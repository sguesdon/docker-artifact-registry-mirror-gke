#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

source "${SCRIPT_DIR}/common.sh"

NAMESPACE=mirror-test
FAKE_REGISTRY_IMAGE_NAME=fake-registry
FAKE_REGISTRY_MANIFEST_FILENAME=./tests/resources/fake-registry-deployment.yaml
MIRROR_RELEASE_NAME=private-gcp-mirror

wait_for_pods_to_be_deleted() {
  local POD_LABEL_SELECTOR=$1

  while kubectl get pods -l "${POD_LABEL_SELECTOR}" | grep -q 'Running\|Pending\|Terminating'; do
    sleep 5
  done
}

get_fake_registry_deployment_selector() {
  MANIFEST_FILENAME=$1
  DEPLOYMENT_SELECTOR=$(yq -r 'select(.kind == "Deployment") | .spec.selector.matchLabels | to_entries | map(.key + "=" + .value) | join(",")' "${MANIFEST_FILENAME}")
  echo "${DEPLOYMENT_SELECTOR}"
}

build_clean_and_deploy_fake_registry_deployment() {
  IMAGE_NAME=$1
  MANIFEST_FILENAME=$2
  DEPLOYMENT_SELECTOR=$(get_fake_registry_deployment_selector "${MANIFEST_FILENAME}")
  DEPLOYMENT_NAME=$(yq -r 'select(.kind == "Deployment") | .metadata.name' "${MANIFEST_FILENAME}")

  echo "--- build fake registry, tests image"
  docker build -t "${FAKE_REGISTRY_IMAGE_NAME}" --no-cache ./tests

  echo "--- cleaning fake registry deployment"
  kubectl delete --ignore-not-found=true -f "${MANIFEST_FILENAME}"
  wait_for_pods_to_be_deleted "${DEPLOYMENT_SELECTOR}"

  echo "--- deploy fake registry deployment"
  kubectl apply -f "${MANIFEST_FILENAME}"
  kubectl wait --timeout=300s --for=condition=available "deployment/${DEPLOYMENT_NAME}"
}

package_clean_and_deploy_mirror_helm_chart() {
  RELEASE_NAME=$1
  NAMESPACE=$2
  PACKAGE_VERSION="0.0.1"
  
  package_mirror_helm_chart "${PACKAGE_VERSION}"

  echo "--- uninstall helm deployment"
  helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" || echo "Helm release not found. Skipping uninstall."
  wait_for_pods_to_be_deleted "app.kubernetes.io/instance=${RELEASE_NAME}"

  echo "--- deploy helm chart"
  helm upgrade --install \
      --namespace "${NAMESPACE}" \
      --values ./tests/resources/config/values.yaml \
      "$RELEASE_NAME" \
      ./docker-gcp-private-mirror-0.0.1.tgz
  kubectl wait --timeout=300s --for=condition=available "deployment/${RELEASE_NAME}"
}

configure_env() {

  if [ -n "$MINIKUBE" ]; then
    echo "--- setup minikube docker env"
    eval $(minikube docker-env)
  fi

  echo "--- create namespace and set current"
  kubectl create namespace "${NAMESPACE}"
  kubectl config set-context --current --namespace="${NAMESPACE}"
}

run_tests_in_fake_registry() {
  MANIFEST_FILENAME=$1
  NAMESPACE=$2

  echo "--- running tests in fake registry container"
  DEPLOYMENT_SELECTOR=$(get_fake_registry_deployment_selector "${MANIFEST_FILENAME}")
  POD_NAME=$(kubectl get pods -n "$NAMESPACE" --no-headers -o custom-columns=":metadata.name" -l "${DEPLOYMENT_SELECTOR}")
  kubectl exec -n "$NAMESPACE" -it "pod/${POD_NAME}" -- npm run test
}

main() {

  configure_env

  build_clean_and_deploy_fake_registry_deployment "${FAKE_REGISTRY_IMAGE_NAME}" "${FAKE_REGISTRY_MANIFEST_FILENAME}"
  package_clean_and_deploy_mirror_helm_chart "${MIRROR_RELEASE_NAME}" "${NAMESPACE}"

  echo "--- pods summary"
  kubectl get pods

  run_tests_in_fake_registry "${FAKE_REGISTRY_MANIFEST_FILENAME}" "${NAMESPACE}"
}

main

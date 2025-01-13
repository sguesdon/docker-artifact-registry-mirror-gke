#!/bin/bash

wait_for_pods_to_be_deleted() {
  local namespace=$1
  local pod_label_selector=$2

  echo "Waiting for all pods with label selector '${pod_label_selector}' to be deleted..."
  while kubectl get pods -n "${namespace}" -l "${pod_label_selector}" | grep -q 'Running\|Pending'; do
    echo "Pods still present. Retrying in 5 seconds..."
    sleep 5
  done
  echo "All pods with label selector '${pod_label_selector}' have been deleted."
}

NAMESPACE=mirror-test

FAKE_REGISTRY_NAME=fake-registry
FAKE_REGISTRY_IMAGE_NAME=fake-registry
FAKE_REGISTRY_SELECTOR="app=${FAKE_REGISTRY_IMAGE_NAME}"
FAKE_REGISTRY_DEPLOYMENT_NAME="${FAKE_REGISTRY_IMAGE_NAME}"

MIRROR_RELEASE_NAME=private-gcp-mirror
MIRROR_DEPLOYMENT_NAME=private-gcp-mirror

# build and deploy test image
if [ -n "$MINIKUBE" ]; then
  echo "setup minikube docker env"
  eval $(minikube docker-env)
fi
 
docker build -t "${FAKE_REGISTRY_IMAGE_NAME}" --no-cache ./tests

kubectl delete --ignore-not-found=true -f ./tests/resources/pod.yaml
wait_for_pods_to_be_deleted "${NAMESPACE}" "${FAKE_REGISTRY_SELECTOR}"

kubectl apply -f ./tests/resources/pod.yaml
echo "Waiting for the Pod to be ready..."
kubectl wait --for=condition=available "deployment/${FAKE_REGISTRY_DEPLOYMENT_NAME}" --timeout=300s

helm uninstall "${MIRROR_RELEASE_NAME}" --namespace "${NAMESPACE}" || echo "Helm release not found. Skipping uninstall."
wait_for_pods_to_be_deleted "${NAMESPACE}" "app.kubernetes.io/instance=${MIRROR_RELEASE_NAME}"

# build and deploy helm chart
helm package ./src --version=0.0.1
helm upgrade --install \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --values ./tests/resources/config/values.yaml \
    "$MIRROR_RELEASE_NAME" \
    ./docker-gcp-private-mirror-0.0.1.tgz

echo "Waiting for the Pod to be ready..."
kubectl wait --for=condition=available "deployment/${MIRROR_DEPLOYMENT_NAME}" --timeout=300s

kubectl get pods -A

# run tests
POD_NAME=$(kubectl get pods --no-headers -o custom-columns=":metadata.name" -l "${FAKE_REGISTRY_SELECTOR}")
kubectl exec -it "pod/${POD_NAME}" -- npm run test

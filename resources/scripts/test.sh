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

POD_NAME=mirror-test
NAMESPACE=mirror-test
RELEASE_NAME=private-gcp-mirror

# build and deploy test image
# eval $(minikube docker-env)
docker build -t mirror-test --no-cache ./tests

kubectl delete --ignore-not-found=true -f ./tests/resources/pod.yaml
wait_for_pods_to_be_deleted "${NAMESPACE}" "app=${POD_NAME}"

kubectl apply -f ./tests/resources/pod.yaml
echo "Waiting for the Pod to be ready..."
kubectl wait --for=condition=Ready "pod/${POD_NAME}" --timeout=300s

helm uninstall "${RELEASE_NAME}" --namespace "${NAMESPACE}" || echo "Helm release not found. Skipping uninstall."
wait_for_pods_to_be_deleted "${NAMESPACE}" "app.kubernetes.io/instance=${RELEASE_NAME}"

# build and deploy helm chart
helm package ./src --version=0.0.1
helm upgrade --install \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --values ./tests/resources/config/values.yaml \
    private-gcp-mirror \
    ./docker-gcp-private-mirror-0.0.1.tgz

echo "Waiting for the Pod to be ready..."
kubectl wait --for=condition=Ready pod/private-gcp-mirror --timeout=300s

# run tests
kubectl exec -it "pod/${POD_NAME}" -- npm run test

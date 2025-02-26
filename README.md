![GitHub License](https://img.shields.io/github/license/sguesdon/docker-artifact-registry-mirror-gke)
[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
![Test Status](https://github.com/sguesdon/docker-artifact-registry-mirror-gke/actions/workflows/tests.yaml/badge.svg?branch=main)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/docker-artifact-registry-mirror-gke)](https://artifacthub.io/packages/helm/docker-artifact-registry-mirror-gke/docker-artifact-registry-mirror-gke)
[![Docker hub](https://img.shields.io/docker/v/sguesdon/docker-artifact-registry-mirror-gke?logo=docker&label=Docker%20hub)](https://hub.docker.com/r/sguesdon/docker-artifact-registry-mirror-gke/builds)

# Docker Artifact Registry Mirror for GKE

This project was created with the aim of using an image mirror from Artifact Registry in a Kubernetes cluster (GKE) within Google Cloud Platform. It addresses several issues, the first being the ability to call a mirror that contains a URL with a URI, not just a hostname (it is possible that Containerd now supports this, but that has not always been the case). It also leverages Workload Identity to automatically add an authorization header to all requests sent to the Artifact Registry image mirror.

## Helm deployment

Before proceeding with the installation, you must have deployed an Artifact Registry repository, have a cluster with Workload Identity enabled, and possess a GCP user with permissions to read from your repository. An [Opentofu example](tests/tofu) is available in the tests folder without the GKE cluster deployment.

> If Workload Identity is not enabled, the service account for your workloads must have read permissions on the Artifact Registry repository.

### Basic configuration

```yaml
# values.yaml
fullnameOverride: gcp-mirror
upstreamHost: "<artifact_registry_location>-docker.pkg.dev"
rewritePath: "<gcp_project_id>/<artifact_registry_name>"
serviceAccount:
  annotations:
    # Do not specify this if you want to use the service account of your nodes.
    iam.gke.io/gcp-service-account: my-gcp-sa@my-sa-project-id.iam.gserviceaccount.com
```

### Command line

```sh
helm install gcp-mirror oci://registry-1.docker.io/sguesdon/docker-artifact-registry-mirror-gke --version <version>
```

### Using Helm chart dependencies

```yaml
# Chart.yaml
# [...]
dependencies:
  - name: docker-artifact-registry-mirror-gke
    alias: gcp-mirror
    version: <version>
    repository: oci://registry-1.docker.io/sguesdon
# [...]
```

## Advanced Configuration

Other configurations are available, including settings related to the NGINX cache. All the values are available [here](src/helm-chart/values.yaml).

## Running tests

To quickly run the project, you need to use [DevBox](https://www.jetify.com/docs/devbox/installing_devbox/) and [direnv](https://www.jetify.com/docs/devbox/ide_configuration/direnv/).

You will need Kubernetes locally to run the tests. Currently, the tests have already been successfully executed on the Kubernetes provided by Docker Desktop and on Minikube.

> Before running your tests, you must ensure that `kubectl` is properly configured to connect to your local cluster.
> If you are using Minikube, you will need to set the following variable: `MINIKUBE=true`

```sh
devbox run test
```

## Quick GCP Deployment for Testing

If you want to quickly test the solution on GCP, you can do so using the Opentofu project located in the [following folder](tests/tofu).
However, you will need to have gcloud properly configured and an active GKE cluster with workload identity.

> If Workload Identity is not enabled, the service account for your workloads must have read permissions on the Artifact Registry repository.

Before deploying the solution, make sure to fill in the minimum configurations in the `terraform.tfvars` file. The `terraform.tfvars.example` file contains the minimum required information.

```sh
cd tests/tofu
tofu init
tofu apply
```

After installation, you can quickly test the solution using the following commands:

```sh
kubectl run dind --rm -it --image=docker:dind --privileged -- --insecure-registry docker-mirror --registry-mirror http://docker-mirror
kubectl exec -it dind -- docker pull redis:latest
```

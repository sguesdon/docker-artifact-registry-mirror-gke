[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
![Test Status](https://github.com/sguesdon/docker-gcp-private-mirror/actions/workflows/tests.yaml/badge.svg?branch=main)

# Docker GCP private mirror

This project was created with the aim of using an image mirror from Artifact Registry in a Kubernetes cluster (GKE) within Google Cloud Platform. It addresses several issues, the first being the ability to call a mirror that contains a URL with a URI, not just a hostname (it is possible that Containerd now supports this, but that has not always been the case). It also leverages Workload Identity to automatically add an authorization header to all requests sent to the Artifact Registry image mirror.

## Installation

Before proceeding with the installation, you must have deployed an Artifact Registry repository, have a cluster with Workload Identity enabled, and possess a GCP user with permissions to read from your repository.

### Command line

```sh
helm install gcp-mirror oci://registry-1.docker.io/sguesdon/docker-gcp-private-mirror --version 0.0.1
```

### Helm chart dependency

```yaml
# Chart.yaml
# [...]
dependencies:
  - name: docker-gcp-private-mirror
    alias: gcp-mirror
    version: 0.0.1
    repository: oci://registry-1.docker.io/sguesdon
# [...]
```

## Required values

```yaml
fullnameOverride: gcp-mirror
nginx:
  proxy:
    # Depends on the location of your Artifact Registry repository.
    upstreamHost: "europe-docker.pkg.dev"
    # This is the missing URI in the mirror configuration to access the repository.
    # It is composed of the Google project ID and the name of the Artifact Registry repository.
    rewritePath: "gcp_project/registry_name"
serviceAccount:
  name: "gcp-mirror"
  annotations:
    # Properly link the Kubernetes service account with the Google service account so that the sidecar can generate the tokens.
    iam.gke.io/gcp-service-account: my-gcp-sa@my-sa-project-id.iam.gserviceaccount.com
```

## All values

Other configurations are available, including settings related to the NGINX cache. The behavior of the sidecar responsible for retrieving the Google token can also be modified.

[values.yaml](src/values.yaml)

## Requirements to run tests locally

To quickly run the project, you need to use [DevBox](https://www.jetify.com/docs/devbox/installing_devbox/) and [direnv](https://www.jetify.com/docs/devbox/ide_configuration/direnv/). I encourage you to install it.

You will need Kubernetes locally to run the tests. Currently, the tests have already been successfully executed on the Kubernetes provided by Docker Desktop and on Minikube.

> Before running your tests, you must ensure that `kubectl` is properly configured to connect to your local cluster.

## Running tests

> If you are using Minikube, you will need to set the following variable: MINIKUBE=true

```sh
devbox run test
```

## Lint helm chart

```sh
devbox run lint
```

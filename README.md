[![Built with Devbox](https://www.jetify.com/img/devbox/shield_galaxy.svg)](https://www.jetify.com/devbox/docs/contributor-quickstart/)
![Test Status](https://github.com/sguesdon/docker-gcp-private-mirror/actions/workflows/tests.yaml/badge.svg?branch=main)

# Docker GCP private mirror

This project was created with the aim of using an image mirror from Artifact Registry in a Kubernetes cluster (GKE) within Google Cloud Platform. It addresses several issues, the first being the ability to call a mirror that contains a URL with a URI, not just a hostname (it is possible that Containerd now supports this, but that has not always been the case). It also leverages Workload Identity to automatically add an authorization header to all requests sent to the Artifact Registry image mirror.

## Installation

Before proceeding with the installation, you must have deployed an Artifact Registry repository, have a cluster with Workload Identity enabled, and possess a GCP user with permissions to read from your repository.

```sh

```

## Customization

## Requirements to run tests locally

To quickly run the project, you need to use Devbox and direnv. Otherwise, I encourage you to install it: [Install DevBox](https://www.jetify.com/docs/devbox/installing_devbox/) [Install direnv](https://www.jetify.com/docs/devbox/ide_configuration/direnv/)

You will need Kubernetes locally to run the tests. Currently, the tests have already been successfully executed on the Kubernetes provided by Docker Desktop and on Minikube.

Before running your tests, you must ensure that `kubectl` is properly configured to connect to your local cluster.

## Running tests

```sh
# If you are using Minikube, you will need to set the following variable: MINIKUBE=true
devbox run test
```

## Lint helm chart

```sh
# If you are using Minikube, you will need to set the following variable: MINIKUBE=true
devbox run lint
```

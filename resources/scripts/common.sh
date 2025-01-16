#!/bin/bash

export HELM_DIR="src/helm-chart/"
export NGINX_IMAGE_NAME=nginx-mirror-test
export NGINX_IMAGE_PATH=./src/docker

build_nginx_image() {
    local DIR=$1
    local IMAGE_NAME=$2

    echo "--- Build nginx image"
    docker build --no-cache -t "${IMAGE_NAME}" "${DIR}"
}

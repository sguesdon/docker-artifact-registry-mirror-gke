export const DOCKER_REGISTRY_VERSION = "v2";
export const PROJECT_NAME = "test-project";
export const REGISTRY_NAME = "test-registry-name";

export const MIRROR_HOSTNAME = "private-gcp-mirror";
export const MOCK_SERVER_HOSTNAME = "fake-registry";

export const ANY_ROUTE_URI = `/any-route/test-image-name`;

export const IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/test-image-name`;
export const FORWARDED_IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/${PROJECT_NAME}/${REGISTRY_NAME}/test-image-name`;

export const ERROR_IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/error-test-image-name`;
export const FORWARDED_ERROR_IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/${PROJECT_NAME}/${REGISTRY_NAME}/error-test-image-name`;

export const MISSING_IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/missing-test-image-name`;
export const FORWARDED_MISSING_IMAGE_NAME_URI = `/${DOCKER_REGISTRY_VERSION}/${PROJECT_NAME}/${REGISTRY_NAME}/missing-test-image-name`;

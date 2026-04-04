#!/bin/sh
set -e

# shellcheck disable=SC2016
envsubst '
    ${DNS_RESOLVER}
    ${PROXY_BUFFER_SIZE}
    ${PROXY_BUFFERS}
    ${PROXY_BUSY_BUFFERS_SIZE}
    ${LARGE_CLIENT_HEADER_BUFFERS}
    ${UPSTREAM_HOST}
    ${UPSTREAM_PROTOCOL}
    ${BASE_REWRITE_PATH}
    ${TOKEN_CACHE_EXPIRATION_SECONDS}
    ${MAX_AUTH_RETRY_ATTEMPTS}
    ${AUTH_TOKEN_ENDPOINT}
' \
    < "/etc/nginx/templates/nginx.conf.template" \
    > "/usr/local/openresty/nginx/conf/nginx.conf"

exec "$@"

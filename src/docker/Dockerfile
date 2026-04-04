ARG OPENRESTY_VERSION=1.25.3.2-alpine-fat
ARG NGINX_VERSION=1.25.3

FROM openresty/openresty:${OPENRESTY_VERSION}

ARG OPENRESTY_VERSION=1.25.3.2-alpine-fat
ARG NGINX_VERSION=1.25.3

LABEL openresty.version=${OPENRESTY_VERSION} \
    nginx.version=${NGINX_VERSION} \
    org.opencontainers.image.title="Docker Artifact Registry Mirror for GKE" \
    org.opencontainers.image.description="Nginx-based mirror for Google Cloud Artifact Registry with automatic authentication using OpenResty ${OPENRESTY_VERSION}" \
    org.opencontainers.image.vendor="sguesdon" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/sguesdon/docker-artifact-registry-mirror-gke"

RUN apk add coreutils gcc musl-dev wget \
    && apk cache clean

RUN opm get ledgetech/lua-resty-http

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

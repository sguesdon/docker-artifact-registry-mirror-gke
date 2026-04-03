ARG OPENRESTY_VERSION=1.25.3.2-alpine-fat

FROM openresty/openresty:${OPENRESTY_VERSION}

# Re-declare ARG after FROM to use in LABELs
ARG OPENRESTY_VERSION

LABEL openresty.version=${OPENRESTY_VERSION} \
    maintainer="sguesdon" \
    description="Docker Artifact Registry Mirror for GKE with OpenResty ${OPENRESTY_VERSION}"

RUN apk add coreutils gcc musl-dev wget \
    && apk cache clean

RUN opm get ledgetech/lua-resty-http

EXPOSE 80

LABEL org.opencontainers.image.title="Docker Artifact Registry Mirror for GKE" \
    org.opencontainers.image.description="Nginx-based mirror for Google Cloud Artifact Registry with automatic authentication" \
    org.opencontainers.image.vendor="sguesdon" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/sguesdon/docker-artifact-registry-mirror-gke"

CMD ["nginx", "-g", "daemon off;"]

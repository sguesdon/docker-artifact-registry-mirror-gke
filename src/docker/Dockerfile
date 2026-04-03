ARG OPENRESTY_VERSION=1.25.3.2-alpine

FROM openresty/openresty:${OPENRESTY_VERSION}

LABEL openresty.version=${OPENRESTY_VERSION} \
    maintainer="sguesdon" \
    description="Docker Artifact Registry Mirror for GKE with OpenResty ${OPENRESTY_VERSION}"

USER root

RUN apk add --no-cache \
    ca-certificates \
    curl \
    tzdata \
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    make \
    wget \
    && rm -rf /var/cache/apk/*

RUN opm install ledgetech/lua-resty-http \
    && luarocks install lua-cjson

RUN apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp \
    && chown -R nginx:nginx /var/cache/nginx \
    && chmod -R 755 /var/cache/nginx

RUN find / -perm +6000 -type f -exec chmod a-s {} \; 2>/dev/null || true

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80

LABEL org.opencontainers.image.title="Docker Artifact Registry Mirror for GKE" \
    org.opencontainers.image.description="Nginx-based mirror for Google Cloud Artifact Registry with automatic authentication" \
    org.opencontainers.image.vendor="sguesdon" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.source="https://github.com/sguesdon/docker-artifact-registry-mirror-gke"

USER nginx

CMD ["nginx", "-g", "daemon off;"]

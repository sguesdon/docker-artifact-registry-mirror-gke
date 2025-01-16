FROM fabiocicerchia/nginx-lua:alpine
RUN apk add gcc musl-dev coreutils wget
RUN luarocks install lua-resty-http \
    && luarocks install lua-cjson

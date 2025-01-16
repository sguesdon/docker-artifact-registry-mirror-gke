FROM fabiocicerchia/nginx-lua:alpine

RUN apk add coreutils gcc musl-dev wget \
    && apk cache clean

RUN luarocks install lua-resty-http \
    && luarocks install lua-cjson

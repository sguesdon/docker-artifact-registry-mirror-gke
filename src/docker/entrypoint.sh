#!/bin/sh
set -e

template_dir="/etc/nginx/templates"
config_dir="/usr/local/openresty/nginx/conf"

if [ -d "$template_dir" ]; then
    echo "Processing nginx templates in $template_dir"
    find "$template_dir" -name "*.template" | while read template_file; do
        relative_path=$(echo "$template_file" | sed "s|^$template_dir/||")
        output_file="$config_dir/$(echo "$relative_path" | sed 's/\.template$//')"
        output_dir=$(dirname "$output_file")
        
        mkdir -p "$output_dir"
        
        echo "Processing $template_file -> $output_file"
        envsubst '${DNS_RESOLVER} ${PROXY_BUFFER_SIZE} ${PROXY_BUFFERS} ${PROXY_BUSY_BUFFERS_SIZE} ${LARGE_CLIENT_HEADER_BUFFERS} ${UPSTREAM_HOST} ${UPSTREAM_PROTOCOL} ${BASE_REWRITE_PATH} ${TOKEN_CACHE_EXPIRATION_SECONDS} ${MAX_AUTH_RETRY_ATTEMPTS} ${AUTH_TOKEN_ENDPOINT}' < "$template_file" > "$output_file"
    done
    echo "Template processing completed"
else
    echo "No template directory found at $template_dir"
fi

exec "$@"

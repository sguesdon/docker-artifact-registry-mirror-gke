#!/bin/sh
while true; do
    gcloud auth application-default print-access-token | tr -d '\n\t\r ' >"${TOKEN_FILE_PATH}"
    [ $? -ne 0 ] && exit 1
    sleep 300
done

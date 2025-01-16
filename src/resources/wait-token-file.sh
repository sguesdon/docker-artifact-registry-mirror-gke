#!/bin/sh
while [ ! -f "$TOKEN_FILE_PATH" ]; do
    echo "Waiting for token file..."
    sleep 1
done

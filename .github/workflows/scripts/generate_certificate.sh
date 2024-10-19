#!/bin/bash

# Define the paths for the certificate and key
CERT_PATH="${1:-./rajmanda-dev.crt}"
KEY_PATH="${2:-./rajmanda-dev.key}"

# Generate the self-signed certificate using OpenSSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$KEY_PATH" \
    -out "$CERT_PATH" \
    -subj "/CN=rajmanda-dev.com"

# Check if the files were created successfully
if [[ -f "$CERT_PATH" && -f "$KEY_PATH" ]]; then
    echo "Certificate and key successfully generated at $CERT_PATH and $KEY_PATH"
    exit 0
else
    echo "Error: Certificate or key not generated!"
    exit 1
fi

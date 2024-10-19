#!/bin/bash

# Check if the key and certificate already exist
if [[ -f ./rajmanda-dev.key ]]; then
    echo "Key file already exists:"
    ls -l ./rajmanda-dev.key
else
    echo "Key file does not exist, will be generated."
fi

if [[ -f ./rajmanda-dev.crt ]]; then
    echo "Certificate file already exists:"
    ls -l ./rajmanda-dev.crt
else
    echo "Certificate file does not exist, will be generated."
fi

# Generate self-signed certificate using OpenSSL
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./rajmanda-dev.key \
  -out ./rajmanda-dev.crt \
  -subj "/CN=rajmanda-dev.com"

# Display success message
echo "Self-signed certificate and key have been generated."

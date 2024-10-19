#!/bin/bash

# Check if the key and certificate already exist
if [[ -f ./rajmanda-dev.key ]] && [[ -f ./rajmanda-dev.crt ]]; then
    echo "Key and Certificate already exist."
else
    echo "Generating self-signed certificate and key..."
    
    # Generate self-signed certificate using OpenSSL
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout ./rajmanda-dev.key \
      -out ./rajmanda-dev.crt \
      -subj "/CN=rajmanda-dev.com"
      
    echo "Self-signed certificate and key have been generated."
fi

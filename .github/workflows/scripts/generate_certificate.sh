#!/bin/bash

# Create dummy TLS certificate and key files
echo "-----BEGIN CERTIFICATE-----" > ./rajmanda-dev.crt
echo "Dummy Certificate" >> ./rajmanda-dev.crt
echo "-----END CERTIFICATE-----" >> ./rajmanda-dev.crt

echo "-----BEGIN PRIVATE KEY-----" > ./rajmanda-dev.key
echo "Dummy Private Key" >> ./rajmanda-dev.key
echo "-----END PRIVATE KEY-----" >> ./rajmanda-dev.key

echo "Dummy files created."


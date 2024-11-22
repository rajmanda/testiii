#!/bin/bash

NAMESPACE=$1

if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo '{"exists": true}'
else
  echo '{"exists": false}'
fi

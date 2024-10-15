 #!/bin/bash

# Add Helm repository if not already added
if ! helm repo list | grep -q "bitnami"; then
    helm repo add bitnami https://charts.bitnami.com/bitnami
fi

# Update Helm repositories
helm repo update

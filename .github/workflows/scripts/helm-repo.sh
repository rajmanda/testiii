#!/bin/bash

# Function to add Helm repositories
add_helm_repos() {
  echo "Adding Helm repositories..."

  # Add Bitnami repository
  helm repo add bitnami https://charts.bitnami.com/bitnami

  # Add NGINX stable repository
  helm repo add nginx-stable https://helm.nginx.com/stable

  # Add any additional repositories here
  echo "Helm repositories added successfully."
}

# Function to list Helm repositories
list_helm_repos() {
  echo "Listing Helm repositories..."
  helm repo list
}

# Function to update Helm repositories
update_helm_repos() {
  echo "Updating Helm repositories..."
  helm repo update
}

# Function to list chart versions for a specific chart
list_chart_versions() {
  local chart_name="$1"
  echo "Available versions for chart '$chart_name':"
  helm search repo "$chart_name" --versions | awk '{print $2, $3}' | tail -n +2 # Exclude header
}

# Main script execution
add_helm_repos
update_helm_repos
list_helm_repos

# List versions for specific charts
list_chart_versions "nginx-ingress"
list_chart_versions "bitnami/nginx-ingress-controller"

echo "Script execution completed."

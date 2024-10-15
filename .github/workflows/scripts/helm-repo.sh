#!/bin/bash

# Set the Helm repositories
REPOS=("bitnami=https://charts.bitnami.com/bitnami" 
       "nginx-stable=https://helm.nginx.com/stable"
       "ygqygq2=https://ygqygq2.github.io/charts")

# Function to add Helm repositories
add_repos() {
  for repo in "${REPOS[@]}"; do
    helm repo add "${repo%%=*}" "${repo#*=}" || { echo "Failed to add repository: ${repo%%=*}"; exit 1; }
  done
  echo "Helm repositories added successfully."
}

# Function to update Helm repositories
update_repos() {
  helm repo update || { echo "Failed to update repositories"; exit 1; }
  echo "Helm repositories updated successfully."
}

# Function to list chart versions
list_chart_versions() {
  CHARTS=("nginx-stable/nginx-ingress" "bitnami/nginx-ingress-controller")

  echo "Listing available chart versions:"
  for chart in "${CHARTS[@]}"; do
    echo "Available versions for chart '$chart':"
    helm search repo "$chart" --versions | awk '{print $1, $2}' | tail -n +2 || { echo "Failed to list versions for $chart"; exit 1; }
  done
}

# Main script execution
add_repos
update_repos
list_chart_versions

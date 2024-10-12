#!/bin/bash
# project/.github/workflows/scripts/check-gke-cluster.sh

CLUSTER_NAME="gke-cluster"
ZONE="us-central1-a"
PROJECT="properties-app-418208"
TFVARS_FILE="../000-vars.tfvars"  # Path to the terraform.tfvars file

# Check if the GKE cluster exists
gcloud container clusters describe $CLUSTER_NAME --zone $ZONE --project $PROJECT &> /dev/null

# Check the result of the command and update the terraform.tfvars file
if [ $? -ne 0 ]; then
  echo "Cluster does not exist. Terraform will create a new cluster."
  echo "skip_cluster_creation = false" > $TFVARS_FILE
else
  echo "Cluster already exists."
  echo "skip_cluster_creation = true" > $TFVARS_FILE
fi


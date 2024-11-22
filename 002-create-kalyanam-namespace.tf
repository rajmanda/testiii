# Data block to refer to the existing GKE cluster
data "google_container_cluster" "existing" {
  name     = "simple-autopilot-public-cluster"  # Replace with your GKE cluster name
  location = "us-central1"                      # Replace with your cluster location
}

# Get the Google client configuration
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.existing.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

data "kubernetes_namespace" "existing" {
  metadata {
    name = "kalyanam"
  }
}

locals {
  namespace_exists = length(data.kubernetes_namespace.existing.*) > 0
}

# Deploy namespace GKE Cluster
resource "kubernetes_namespace" "kalyanam" {
  count = local.namespace_exists ? 0 : 1

  metadata {
    name = "kalyanam"
  }

  depends_on = [data.google_container_cluster.existing]
}

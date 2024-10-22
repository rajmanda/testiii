# Data block to refer to the existing GKE cluster
data "google_container_cluster" "existing" {
  name     = "simple-autopilot-public-cluster"  # Replace with your GKE cluster name
  location = "us-central1"                      # Replace with your cluster location
}

# Get the Google client configuration
data "google_client_config" "default" {}

# Get the GKE cluster data
data "google_container_cluster" "primary" {
  name     = "simple-autopilot-public-cluster"  # Replace with your GKE cluster name
  location = "us-central1"  # Adjust as needed
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.existing.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Define the Helm provider
provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.existing.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Step 1: Create a directory for the charts first
resource "null_resource" "prepare_eureka_chart" {
  depends_on = [data.google_container_cluster.existing]

  provisioner "local-exec" {
    command = <<EOT
      echo "Creating directory for Eureka charts..."
      mkdir -p ./eureka/charts
      echo "RAJ - Directory './eureka/charts' created successfully."
    EOT
  }
}

# Step 2: Fetch and extract the charts
resource "null_resource" "fetch_and_extract_charts" {
  depends_on = [null_resource.prepare_eureka_chart]

  provisioner "local-exec" {
    command = <<EOT
      echo "Fetching Eureka chart..."
      helm fetch ygqygq2/eureka --version 2.0.0
      echo "Fetching Bitnami common chart..."
      helm fetch bitnami/common --version 2.26.0

      if [ -f eureka-2.0.0.tgz ]; then
        echo "Extracting Eureka chart..."
        tar -xvzf eureka-2.0.0.tgz                # this will extract to ./eureka
        echo "Eureka chart extracted successfully."
      else
        echo "Eureka chart not found!"
        exit 1
      fi

      if [ -f common-2.26.0.tgz ]; then
        echo "Extracting Common chart..."
        tar -xvzf common-2.26.0.tgz -C ./eureka/charts
        echo "Common chart extracted successfully."
      else
        echo "Common chart not found!"
        exit 1
      fi
    EOT
  }
}

# Install the Eureka Helm chart
resource "helm_release" "eureka" {
  depends_on = [null_resource.fetch_and_extract_charts]

  name       = "my-eureka"
  chart      = "./eureka"
  version    = "2.0.0"
  namespace  = "eureka"

  set {
    name  = "REGISTER_WITH_EUREKA"
    value = "False"
  }

  set {
    name  = "FETCH_REGISTRY"
    value = "False"
  }

  set {
    name  = "ENABLE_SELF_PRESERVATION"
    value = "False"
  }

  set {
    name  = "replicaCount"
    value = "1"
  }
}

# Optional: Output Eureka Helm release status
output "eureka_helm_release_status" {
  value = helm_release.eureka.status
}

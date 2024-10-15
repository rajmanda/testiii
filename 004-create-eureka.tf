# # Get the Google client configuration
# data "google_client_config" "default" {}

# # Get the GKE cluster data
# data "google_container_cluster" "gke_cluster" {
#   name     = "gke-cluster"    # Your cluster name
#   location = "us-central1-a"  # Cluster location
# }

# # Define the Kubernetes provider
# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
# }

# # Define the Helm provider
# provider "helm" {
#   kubernetes {
#     host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
#     token                  = data.google_client_config.default.access_token
#     cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
#   }
# }

# Deploy resources on GKE
resource "kubernetes_namespace" "eureka" {
  metadata {
    name = "eureka"
  }
}

# Deploy the Eureka Server using Helm 
resource "helm_release" "eureka" {
  name       = "my-eureka"
  repository = "https://ygqygq2.github.io/charts/"  # Eureka chart repository
  chart      = "eureka"                             # Chart name
  version    = "2.0.0"                              # Specific version

  namespace  = "eureka"                            # Specify the namespace to deploy

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
}

# Output the Eureka Helm release status
output "eureka_helm_release_status" {
  value = helm_release.eureka.status
}

# Output the Eureka service endpoint (if exposed as a service)
# Data source to fetch Eureka service details
data "kubernetes_service" "eureka_service" {
  metadata {
    name      = "my-eureka"  # Change this to the actual Eureka service name
    namespace = "eureka"    # Adjust the namespace if needed
  }
}

# Output the Eureka service LoadBalancer IP (or ClusterIP if applicable)
output "eureka_service_endpoint" {
  value = data.kubernetes_service.eureka_service.status.0.load_balancer.0.ingress[0].ip
}



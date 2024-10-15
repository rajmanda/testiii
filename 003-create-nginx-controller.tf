# Get the GKE cluster data
data "google_container_cluster" "gke_cluster" {
  name     = "gke-cluster"    # Your cluster name
  location = "us-central1-a"  # Cluster location
}

# Get the Google client configuration
data "google_client_config" "default" {}

# Define the Kubernetes provider
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

# Define the Helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Alternatively, use the Kubernetes provider config
  }
}
# Deploy resources on GKE
resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "ingress-nginx"
    }

    labels = {
      mylabel = "ingress-nginx"
    }

    name = "ingress-nginx"
  }
}

# Deploy the NGINX Ingress Controller using Helm
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "bitnami/nginx-ingress-controller"  # Use Bitnami repository
  chart      = "nginx-ingress-controller"
  version    = "11.4.4"                            # Update this to the latest chart version
  namespace  = "ingress-nginx"

  values = [
    <<EOF
controller:
  service:
    enabled: true
    annotations:
      cloud.google.com/load-balancer-type: "External"
    loadBalancerIP: "34.44.172.58"  # Specify your static external IP here
EOF
  ]
}

# Output the NGINX Ingress Controller service endpoint
output "nginx_ingress_service" {
  value = helm_release.nginx_ingress.status
}

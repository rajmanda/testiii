output "kubernetes_cluster_endpoint" {
  value = data.google_container_cluster.primary.endpoint
}

# Get the Google client configuration
data "google_client_config" "default" {}

# Get the GKE cluster data
data "google_container_cluster" "primary" {
  name     = "simple-autopilot-public-cluster"  # Replace with your GKE cluster name
  location = "us-central1"  # Adjust as needed
}

provider "kubernetes" {
  host                   = "https://${module.kubernetes-engine_example_simple_autopilot_public.kubernetes_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Define the Helm provider
provider "helm" {
  kubernetes {
    host                   = "https://${module.kubernetes-engine_example_simple_autopilot_public.kubernetes_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# Deploy resources on GKE
resource "kubernetes_namespace" "nginxns" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "ingress-nginx"
  }
}

# resource "google_compute_global_address" "global_static_ip" {
#   name = "global-ngnix-loadbalancer-ip"
# }

resource "google_compute_address" "regional_static_ip" {
  name   = "regional-ngnix-loadbalancer-ip"
  region = "us-central1"  # Specify the region where you want the static IP
  lifecycle {
    prevent_destroy = true  # Prevent Terraform from deleting this resource
  }
}

# Use the nginx-stable repository for the Helm release
resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_namespace.nginxns]
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "1.4.0"  # Specify the desired chart version
  namespace  = kubernetes_namespace.nginxns.metadata[0].name  # Specify the namespace

  values = [
    <<EOF
controller:
  service:
    enabled: true
    annotations:
      cloud.google.com/load-balancer-type: "External"  # Specify load balancer type
    loadBalancerIP: "${google_compute_address.regional_static_ip.address}"  # Reference the static IP created above
  metrics:
    enabled: true
  replicaCount: 1  # Set number of replicas to 1
EOF
  ]

  set {
    name  = "controller.service.annotations.prometheus\\.io/port"
    value = "9127"
    type  = "string"
  }
}


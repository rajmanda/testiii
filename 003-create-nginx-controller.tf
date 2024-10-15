# Data source to fetch the Google container cluster
data "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = "us-central1-a"  # Make sure this matches the location of your cluster
}

# Add the Helm provider
provider "helm" {
  kubernetes {
    cluster_ca_certificate = data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate
    host                   = data.google_container_cluster.primary.endpoint
    token                  = data.google_container_cluster.primary.master_auth[0].access_token
  }
}

# Install the NGINX Ingress controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "bitnami/nginx-ingress-controller"  # Use Bitnami repository
  chart      = "nginx-ingress-controller"
  version    = "11.4.4"  # Update this to the latest chart version; get this by running `helm search repo nginx-ingress`
  namespace  = "kube-system"
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

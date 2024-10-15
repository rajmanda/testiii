# Data source to fetch Google client configuration
data "google_client_config" "default" {}

# Add the Helm provider
provider "helm" {
  kubernetes {
    cluster_ca_certificate = data.google_client_config.default.cluster_ca_certificate
    host                   = data.google_client_config.default.endpoint
    token                  = data.google_client_config.default.access_token
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

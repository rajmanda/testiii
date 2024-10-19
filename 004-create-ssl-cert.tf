# Define the Kubernetes namespace
resource "kubernetes_namespace" "kalyanam" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "kalyanam"
  }
}

# Create a self-signed certificate using OpenSSL and save the output to specific absolute paths
resource "null_resource" "generate_certificate" {
  depends_on = [kubernetes_namespace.kalyanam]
  
  # Change the absolute path to the desired location
  provisioner "local-exec" {
    command = <<EOT
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /absolute/path/to/rajmanda-dev.key \
      -out /absolute/path/to/rajmanda-dev.crt \
      -subj "/CN=rajmanda-dev.com"
    EOT
  }

  # Trigger this block to always run
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Optional: Introduce a delay to ensure the file is generated properly
resource "null_resource" "delay_after_certificate_generation" {
  depends_on = [null_resource.generate_certificate]
  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# Read the generated certificate from the absolute path
data "local_file" "tls_cert" {
  depends_on = [null_resource.delay_after_certificate_generation]
  filename   = "/absolute/path/to/rajmanda-dev.crt"
}

# Read the generated private key from the absolute path
data "local_file" "tls_key" {
  depends_on = [data.local_file.tls_cert]
  filename   = "/absolute/path/to/rajmanda-dev.key"
}

# Create a Kubernetes secret to store the TLS certificate and private key
resource "kubernetes_secret" "rajmanda_dev_tls" {
  depends_on = [data.local_file.tls_key]
  
  metadata {
    name      = "rajmanda-dev-tls"
    namespace = "kalyanam"
  }

  data = {
    "tls.crt" = base64encode(data.local_file.tls_cert.content)
    "tls.key" = base64encode(data.local_file.tls_key.content)
  }

  type = "kubernetes.io/tls"
}

# Output the existing static IP for use in the Helm release
data "google_compute_address" "existing_static_ip" {
  name   = "regional-nginx-loadbalancer-ip"
  region = "us-central1"
}

output "existing_static_ip_address" {
  value = data.google_compute_address.existing_static_ip.address
}

# Deploy NGINX ingress controller on GKE using Helm
resource "helm_release" "nginx_ingress" {
  depends_on = [kubernetes_namespace.kalyanam]
  
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "1.4.0"
  namespace  = kubernetes_namespace.kalyanam.metadata[0].name

  values = [
    <<EOF
controller:
  service:
    enabled: true
    annotations:
      cloud.google.com/load-balancer-type: "External"
    loadBalancerIP: "${data.google_compute_address.existing_static_ip.address}"
  metrics:
    enabled: true
  replicaCount: 1
EOF
  ]

  set {
    name  = "controller.service.annotations.prometheus\\.io/port"
    value = "9127"
    type  = "string"
  }
}

# Deploy resources on GKE
resource "kubernetes_namespace" "eureka" {
  #depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  depends_on = [ data.google_container_cluster.existing ]
  metadata {
    name = "eureka"
  }
}

# Configure the TLS provider
provider "tls" {}

# Generate a private key
resource "tls_private_key" "example" {
  depends_on = [ kubernetes_namespace.eureka ]
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Generate a self-signed TLS certificate
resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "rajmanda-dev.com"
    organization = "Rajmanda, LLC"
  }

  # List of DNS names for which the certificate is valid
  dns_names = ["rajmanda-dev.com", "www.rajmanda-dev.com"]  # Add SAN entries here

  validity_period_hours = 24 * 365

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Create a Kubernetes Secret from the generated TLS certificate and key
resource "kubernetes_secret" "tls_secret" {
  metadata {
    name      = "rajmanda-dev-tls"
    namespace = "eureka"
  }

  data = {
    "tls.crt" = tls_self_signed_cert.example.cert_pem  # Correct key name
    "tls.key" = tls_private_key.example.private_key_pem  # Correct key name
  }

  type = "kubernetes.io/tls"
}

# Output the secret name
output "secret_name" {
  value = kubernetes_secret.tls_secret.metadata[0].name
}

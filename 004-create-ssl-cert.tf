# Configure the TLS provider
provider "tls" {}

# Generate a self-signed TLS certificate
resource "tls_self_signed_cert" "example" {
  private_key_pem = file("private_key.pem")

  subject {
    common_name  = "rajmanda-dev.com"
    organization = "Rajmanda, LLC"
  }

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
    name      = "tls-secret"
    namespace = "kalyanam"
  }

  data = {
    tls.crt = tls_self_signed_cert.example[0].cert_pem
    tls.key = tls_self_signed_cert.example[0].private_key_pem
  }

  type = "kubernetes.io/tls"
}

# Output the secret name
output "secret_name" {
  value = kubernetes_secret.tls_secret.metadata[0].name
}

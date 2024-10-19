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

  provisioner "local-exec" {
    command = <<EOT
      chmod +x ./generate_certificate.sh
      "./generate_certificate.sh ./scripts/rajmanda-dev.crt ./scripts/rajmanda-dev.key"
    EOT
  }

  # Trigger this block to always run
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Read the generated certificate from the absolute path
data "local_file" "tls_cert" {
  depends_on = [null_resource.generate_certificate]
  filename   = "./scripts/rajmanda-dev.crt"
}

# Read the generated private key from the absolute path
data "local_file" "tls_key" {
  depends_on = [data.local_file.tls_cert]
  filename   = "./scripts/rajmanda-dev.key"
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

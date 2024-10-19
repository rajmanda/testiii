# Define the Kubernetes namespace
resource "kubernetes_namespace" "kalyanam" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "kalyanam"
  }
}

# Make the Bash script executable and run it to generate the certificate
resource "null_resource" "generate_certificate" {
  depends_on = [kubernetes_namespace.kalyanam]

  provisioner "local-exec" {
    command = <<EOT
      chmod +x ./generate_certificate.sh
      "./generate_certificate.sh ./rajmanda-dev.crt ./rajmanda-dev.key"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

# Optional: Introduce a delay to ensure the files are generated properly
resource "null_resource" "delay_after_certificate_generation" {
  depends_on = [null_resource.generate_certificate]
  provisioner "local-exec" {
    command = "sleep 5"
  }
}

# Read the generated certificate
data "local_file" "tls_cert" {
  depends_on = [null_resource.delay_after_certificate_generation]
  filename   = "${path.module}/scripts/rajmanda-dev.crt"
}

# Read the generated private key
data "local_file" "tls_key" {
  depends_on = [data.local_file.tls_cert]
  filename   = "${path.module}/scripts/rajmanda-dev.key"
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

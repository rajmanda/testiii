# Define the Kubernetes namespace
resource "kubernetes_namespace" "kalyanam" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "kalyanam"
  }
}

# Create a self-signed certificate using OpenSSL and save the output to the local directory
resource "null_resource" "generate_certificate" {
  depends_on = [kubernetes_namespace.kalyanam]

  provisioner "local-exec" {
    command = <<EOT
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout ${path.module}/rajmanda-dev.key \
      -out ${path.module}/rajmanda-dev.crt \
      -subj "/CN=rajmanda-dev.com"
      chmod 600 /absolute/path/to/rajmanda-dev.key
      chmod 600 /absolute/path/to/rajmanda-dev.crt
    EOT
  }

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

# Read the generated certificate
data "local_file" "tls_cert" {
  depends_on = [null_resource.delay_after_certificate_generation]
  filename   = "${path.module}/rajmanda-dev.crt"
}

# Read the generated private key
data "local_file" "tls_key" {
  depends_on = [data.local_file.tls_cert]
  filename   = "${path.module}/rajmanda-dev.key"
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

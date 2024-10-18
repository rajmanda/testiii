

# Deploy resources on GKE
resource "kubernetes_namespace" "kalyanam" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "kalyanam"
  }
}

# Generate a self-signed certificate using OpenSSL
resource "null_resource" "generate_certificate" {
  depends_on = [kubernetes_namespace.kalyanam]
  provisioner "local-exec" {
    command = <<EOT
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout ${path.module}/rajmanda-dev.key \
      -out ${path.module}/rajmanda-dev.crt \
      -subj "/CN=rajmanda-dev.com"
    EOT
  }

  #Run this only if the certificate does not already exist
  triggers = {
    always_run = "${timestamp()}"
  }
}

# Read the generated certificate and key from the file
data "local_file" "tls_cert" {
  filename = "${path.module}/rajmanda-dev.crt"
  depends_on = [null_resource.generate_certificate]
}

data "local_file" "tls_key" {
  filename = "${path.module}/rajmanda-dev.key"
  depends_on = [null_resource.generate_certificate]
}

# Create a Kubernetes secret using the generated certificate and key
resource "kubernetes_secret" "rajmanda_dev_tls" {
  depends_on = [kubernetes_namespace.nginxns]
  metadata {
    name      = "rajmanda-dev-tls"
    namespace = "kalyanam"
  }

  data = {
    "tls.crt" = base64encode(data.local_file.tls_cert.content)
    "tls.key"  = base64encode(data.local_file.tls_key.content)
  }

  type = "kubernetes.io/tls"
}

# Deploy resources on GKE
resource "kubernetes_namespace" "kalyanam" {
  depends_on = [module.kubernetes-engine_example_simple_autopilot_public]
  metadata {
    name = "kalyanam"
  }
}

resource "null_resource" "generate_certificate" {
  depends_on = [kubernetes_namespace.kalyanam]
  provisioner "local-exec" {
    command = <<EOT
      openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout rajmanda-dev.key \
      -out rajmanda-dev.crt \
      -subj "/CN=rajmanda-dev.com"
      echo "Certificate and key generated"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "null_resource" "delay" {
  depends_on = [null_resource.generate_certificate]
  provisioner "local-exec" {
    command = "sleep 10"  # Add a delay to ensure files are available
  }
}


data "local_file" "tls_cert" {
  depends_on = [null_resource.generate_certificate]
  filename   = "${path.cwd}/rajmanda-dev.crt"  # Use ${path.cwd} to ensure correct absolute path
}

data "local_file" "tls_key" {
  depends_on = [data.local_file.tls_cert]
  filename   = "${path.cwd}/rajmanda-dev.key"  # Use ${path.cwd} to ensure correct absolute path
}


# Create a Kubernetes secret using the generated certificate and key
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

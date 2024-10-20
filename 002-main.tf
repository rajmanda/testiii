#Declare all the resources that are already present 

# Data resource for existing Kubernetes Namespace
data "kubernetes_namespace" "eurekans" {
  metadata {
    name = "eureka"
  }
}

# Data resource for existing Kubernetes Secret
data "kubernetes_secret" "tls_secret" {
  metadata {
    name      = "rajmanda-dev-tls"
    namespace = "eureka"
  }
}

# Data resource for existing Helm Release
data "helm_release" "eureka" {
  name      = "my-eureka"
  namespace = "eureka"
}

# Use the data resource to fetch the existing Kubernetes cluster information
data "google_container_cluster" "primary" {
  name     = "simple-autopilot-public-cluster"
  location = "us-central1"
}

# Use the data resource to fetch the existing client configuration
data "google_client_config" "default" {}

# Use null resources for chart extraction and preparation
resource "null_resource" "fetch_and_extract_charts" {
  provisioner "local-exec" {
    command = "echo 'Fetching and extracting charts...'"
  }
}

resource "null_resource" "move_common_chart" {
  provisioner "local-exec" {
    command = "echo 'Moving common chart...'"
  }
}

resource "null_resource" "prepare_eureka_chart" {
  provisioner "local-exec" {
    command = "echo 'Preparing Eureka chart...'"
  }
}

# Data resource for existing TLS private key
data "tls_private_key" "example" {
  algorithm = "RSA"
}

# Data resource for existing self-signed certificate
data "tls_self_signed_cert" "example" {
  dns_names = [
    "rajmanda-dev.com",
    "www.rajmanda-dev.com",
  ]
}

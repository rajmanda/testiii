#Declare all the resources that are already present 

# Kubernetes Namespace - Use Data Resource for Existing Namespace
data "kubernetes_namespace" "eurekans" {
  metadata {
    name = "eureka"
  }
}

# Kubernetes Secret - Use Data Resource for Existing Secret
data "kubernetes_secret" "tls_secret" {
  metadata {
    name      = "rajmanda-dev-tls"
    namespace = "eureka"
  }
}

# Helm Release - Manage Helm Release (remove the data block)
resource "helm_release" "eureka" {
  atomic  = false
  chart   = "./eureka"
  name    = "my-eureka"
  version = "2.0.0"
  namespace = "eureka"

  set {
    name  = "ENABLE_SELF_PRESERVATION"
    value = "False"
  }

  set {
    name  = "FETCH_REGISTRY"
    value = "False"
  }

  set {
    name  = "REGISTER_WITH_EUREKA"
    value = "False"
  }

  set {
    name  = "replicaCount"
    value = "1"
  }
}

# TLS Key and Cert should not use data resources since they are not supported
# You may reference the keys/certs from external files instead if you already have them.

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem
  dns_names       = ["rajmanda-dev.com", "www.rajmanda-dev.com"]
  validity_period_hours = 8760

  subject {
    common_name  = "rajmanda-dev.com"
    organization = "Rajmanda, LLC"
  }

  allowed_uses = ["key_encipherment", "digital_signature", "server_auth"]
}

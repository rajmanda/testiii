# Step 1: Create a directory for the charts
resource "null_resource" "prepare_eureka_chart" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ./eureka/charts
    EOT
  }
}

# Step 2: Fetch and extract the charts
resource "null_resource" "fetch_and_extract_charts" {
  depends_on = [null_resource.prepare_eureka_chart]

  provisioner "local-exec" {
    command = <<EOT
      helm fetch ygqygq2/eureka --version 2.0.0
      helm fetch bitnami/common --version 2.26.0
      tar -xvzf eureka-2.0.0.tgz
      tar -xvzf common-2.26.0.tgz
    EOT
  }
}

# Step 3: Move the common chart into the eureka chart's charts/ directory
resource "null_resource" "move_common_chart" {
  depends_on = [null_resource.fetch_and_extract_charts]

  provisioner "local-exec" {
    command = <<EOT
      mv common ./eureka/charts/
    EOT
  }
}

# Step 4: Install the Eureka Helm chart
resource "helm_release" "eureka" {
  depends_on = [null_resource.move_common_chart]
  
  name       = "my-eureka"
  chart      = "./eureka"  # Use the local directory after modifying the chart structure
  version    = "2.0.0"

  namespace  = "eureka"

  set {
    name  = "REGISTER_WITH_EUREKA"
    value = "False"
  }

  set {
    name  = "FETCH_REGISTRY"
    value = "False"
  }

  set {
    name  = "ENABLE_SELF_PRESERVATION"
    value = "False"
  }
}

# Optional: Output Eureka Helm release status
output "eureka_helm_release_status" {
  value = helm_release.eureka.status
}

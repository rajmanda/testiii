# Step 1: Create a directory for the charts first
resource "null_resource" "prepare_eureka_chart" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Creating directory for Eureka charts..."
      mkdir -p ./eureka/charts
      echo "RAJ - Directory './eureka/charts' created successfully."
    EOT
  }
}

# Step 2: Fetch and extract the charts
resource "null_resource" "fetch_and_extract_charts" {
  depends_on = [null_resource.prepare_eureka_chart]

  provisioner "local-exec" {
    command = <<EOT
      echo "Fetching Eureka chart..."
      helm fetch ygqygq2/eureka --version 2.0.0

      echo "Fetching Bitnami common chart..."
      helm fetch bitnami/common --version 2.26.0

      if [ -f eureka-2.0.0.tgz ]; then
        echo "Extracting Eureka chart..."
        tar -xvzf eureka-2.0.0.tgz
        echo "Eureka chart extracted successfully."
      else
        echo "Eureka chart not found!"
        exit 1
      fi

      if [ -f common-2.26.0.tgz ]; then
        echo "Extracting Common chart..."
        tar -xvzf common-2.26.0.tgz
        echo "Common chart extracted successfully."
      else
        echo "Common chart not found!"
        exit 1
      fi
    EOT
  }
}

# Step 3: Move the common chart into the eureka chart's charts/ directory
resource "null_resource" "move_common_chart" {
  depends_on = [null_resource.fetch_and_extract_charts]

  provisioner "local-exec" {
    command = <<EOT
      echo "Moving common chart into the Eureka charts directory..."
      if [ -d common ]; then
        mv common ./eureka/charts/
        echo "Common chart moved to './eureka/charts/'."
      else
        echo "Common directory not found!"
        exit 1
      fi

      echo "Contents of './eureka/charts/':"
      ls -l ./eureka/charts/
    EOT
  }
}

# Step 4: Create namespace eureka
resource "kubernetes_namespace" "eurekans" {
  depends_on = [null_resource.move_common_chart]
  metadata {
    name = "eureka"
  }
}

# Install the Eureka Helm chart
resource "helm_release" "eureka" {
  depends_on = [kubernetes_namespace.eurekans]
  
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
  
  set {
    name  = "replicaCount"
    value = "1"
  }

  # Debugging output for Helm release creation
  provisioner "local-exec" {
    command = <<EOT
      echo "Preparing to install the Eureka Helm release..."
      echo "Checking the contents of the './eureka' directory before installation:"
      ls -l ./eureka
    EOT
  }
}

# Optional: Output Eureka Helm release status
output "eureka_helm_release_status" {
  value = helm_release.eureka.status
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service


# Data source to check if the Compute Engine API is enabled
# Data source to check if Compute Engine API is enabled
data "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

# Data source to check if Kubernetes Engine API is enabled
data "google_project_service" "container" {
  service = "container.googleapis.com"
}

# Resource to ensure Compute Engine API is enabled
resource "google_project_service" "compute" {
  service                 = "compute.googleapis.com"
  disable_on_destroy      = true  # Keeps service enabled even if destroyed
  disable_dependent_services = true  # Disables dependent services automatically
}

# Resource to ensure Kubernetes Engine API is enabled
resource "google_project_service" "container" {
  service                 = "container.googleapis.com"
  disable_on_destroy      = true  # Keeps service enabled even if destroyed
  disable_dependent_services = true  # Disables dependent services automatically
}

# Output to show if the APIs are enabled
output "compute_api_enabled" {
  value = length(data.google_project_service.compute) > 0 ? "Enabled" : "Disabled"
}

output "container_api_enabled" {
  value = length(data.google_project_service.container) > 0 ? "Enabled" : "Disabled"
}


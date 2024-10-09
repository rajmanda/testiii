# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service


# Data source to check if the Compute Engine API is enabled
data "google_project_service" "compute" {
  project = "properties-app-418208"
  service = "compute.googleapis.com"
}

# Data source to check if the Kubernetes Engine API is enabled
data "google_project_service" "container" {
  project = "properties-app-418208"
  service = "container.googleapis.com"
}

# Enable Compute Engine API if not already enabled
resource "google_project_service" "compute" {
  count                   = data.google_project_service.compute ? 0 : 1
  project                = "properties-app-418208"
  service                = "compute.googleapis.com"
  disable_on_destroy     = true
  disable_dependent_services = true
}

# Enable Kubernetes Engine API if not already enabled
resource "google_project_service" "container" {
  count                   = data.google_project_service.container ? 0 : 1
  project                = "properties-app-418208"
  service                = "container.googleapis.com"
  disable_on_destroy     = true
}





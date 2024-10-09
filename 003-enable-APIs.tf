# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service


# Data source to check if the Compute Engine API is enabled
data "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

data "google_project_service" "container" {
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  count                   = length(data.google_project_service.compute) == 0 ? 1 : 0
  service                 = "compute.googleapis.com"
  disable_on_destroy      = true  # Keeps service enabled even if destroyed
  disable_dependent_services = true  # Disables dependent services automatically
}

resource "google_project_service" "container" {
  count                   = length(data.google_project_service.container) == 0 ? 1 : 0
  service                 = "container.googleapis.com"
  disable_on_destroy      = true  # Keeps service enabled even if destroyed
}






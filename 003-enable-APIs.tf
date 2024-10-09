# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = true  # Keeps service enabled even if destroyed
  disable_dependent_services = true  # Disables dependent services automatically
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
  disable_on_destroy = true  # Keeps service enabled even if destroyed
}




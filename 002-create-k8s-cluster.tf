# Creates GKE cluster with name - simple-autopilot-public-cluster
module "kubernetes-engine_example_simple_autopilot_public" {
  source  = "terraform-google-modules/kubernetes-engine/google//examples/simple_autopilot_public"
  version = "33.1.0"
  project_id = "properties-app-418208"
}

resource "google_compute_firewall" "allow_http" {
  depends_on = [ module.kubernetes-engine_example_simple_autopilot_public ]
  name    = "allow-http"
  network = module.kubernetes-engine_example_simple_autopilot_public.network_name  # Replace with the actual output key if available

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-server"]
}

resource "google_compute_firewall" "allow_https" {
  depends_on = [ module.kubernetes-engine_example_simple_autopilot_public ]
  name    = "allow-https"
  network = module.kubernetes-engine_example_simple_autopilot_public.network_name  # Replace with the actual output key if available

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["https-server"]
}
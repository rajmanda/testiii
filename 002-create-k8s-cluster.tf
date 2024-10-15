resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = "us-central1-a"  # Specify a specific zone

  # Disable the default node pool
  remove_default_node_pool = true
  initial_node_count       = 1  # Required by Terraform even though default pool is removed

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"  # Allow all networks for public access
      display_name = "Public access"
    }
  }
  deletion_protection = false

  network    = "default"
  subnetwork = "default"
}

# Create firewall rule to allow port 443
resource "google_compute_firewall" "allow_443_gke_api" {
  name    = "allow-443-kubernetes-api"
  network = "default"  # Explicitly set the network

  direction = "INGRESS"
  priority  = 1000

  # Allow traffic on port 443 (HTTPS)
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"] # Allow from anywhere. Adjust based on security needs.

  # Apply the rule to the GKE nodes
  target_tags = ["gke-node"]  # Use the correct tag associated with GKE nodes.
}

# Manage GKE node pool separately
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-nodes"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_config {
    machine_type = "e2-small"  # gcloud compute machine-types list --zones=us-central1-a --sort-by=guestCpus --format="table(name, guestCpus, memoryMb, description)"
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags         = ["gke-node"]  # Attach tags for firewall rules
  }

  initial_node_count = 2
}

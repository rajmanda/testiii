resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = "us-central1-a"  # Specify a specific zone

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"  # Allow all networks for public access
      display_name = "Public access"
    }
  }

  initial_node_count  = 1  # This can be set to a minimal value, as the actual nodes will be managed by node pools
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
    machine_type = "e2-micro"  # Use the machine type you need
    disk_size_gb = 50
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags         = ["gke-node"]  # Attach tags for firewall rules
  }

  initial_node_count = 3
}

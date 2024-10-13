# Conditionally create the cluster if it doesn't exist
resource "google_container_cluster" "primary" {
  #count = var.skip_cluster_creation ? 0 : 1
  name  = "gke-cluster"
  location = "us-central1-a"  # Specify a specific zone

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"  # Define the master CIDR block
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.0.0/8"  # Replace with your authorized network CIDR
      display_name = "Authorized network"
    }
  }

  initial_node_count   = 2
  deletion_protection  = false

  node_config {
    machine_type     = "e2-medium"
    disk_size_gb     = 50
    oauth_scopes     = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    #enable_external_ips = false  # Disable external IPs for more security
  }

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

# Attach tags to the GKE nodes (this is necessary to apply firewall rules)
resource "google_container_node_pool" "primary_nodes" {
  #count      = var.skip_cluster_creation ? 0 : 1
  name       = "primary-nodes"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_config {
    machine_type = "e2-medium"
    tags         = ["gke-node"]  # This tag should match the target_tags in the firewall rule
  }

  initial_node_count = 3
}

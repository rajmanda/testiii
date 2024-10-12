resource "google_container_cluster" "primary" {
  name     = "gke-cluster"
  location = "us-central1-a"  # Specify a specific zone

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "172.16.0.0/28"  # Define the master CIDR block
  }

  master_authorized_networks_config {
    # Specify the authorized networks
    cidr_blocks {
      cidr_block   = "10.0.0.0/8"  # Replace with your authorized network CIDR
      display_name = "Authorized network"
    }
  }

  initial_node_count = 2
  deletion_protection = false

  node_config {
    machine_type     = "e2-medium"
    disk_size_gb     = 50
    oauth_scopes     = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    #enable_external_ips = false  # Disable external IPs
  }

  network    = "default"
  subnetwork = "default"
}

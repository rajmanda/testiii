# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall
#The next resource is a firewall. We don't need to create any firewalls manually for GKE; it's just to give you an example. This firewall will allow sshing to the compute instances within VPC.

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

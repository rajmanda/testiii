/*
resource "google_compute_address" "regional_static_ip" {
  name   = "regional-ngnix-loadbalancer-ip"
  region = "us-central1"  # Specify the region where you want the static IP
  lifecycle {
    prevent_destroy = true  # Prevent Terraform from deleting this resource
  }
}
output "static_ip_address" {
  value = google_compute_address.regional_static_ip.address
}
*/
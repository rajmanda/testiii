resource "google_storage_bucket" "tf_state" {
  name     = "tf-gcp-wif-tfstate"
  location = "US"  # Choose your desired location

  # Enable versioning
  versioning {
    enabled = true
  }

  # Optional settings (customize as needed)
  lifecycle {
    prevent_destroy = true
  }
}

terraform {
  backend "gcs" {
    bucket  = google_storage_bucket.tf_state.name
    prefix  = "tf/state"
  }
}


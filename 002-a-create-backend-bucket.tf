# Create the bucket only if it does not exist
resource "google_storage_bucket" "tf_state" {
  name     = "tf-gcp-wif-tfstate"  # Your bucket name
  location = "US"  # Set your desired location
  versioning {
    enabled = true                   # Enable versioning
  }
}
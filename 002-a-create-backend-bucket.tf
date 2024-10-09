# Check if the bucket exists
data "google_storage_bucket" "existing" {
  name = "tf-gcp-wif-tfstate"  # Your bucket name
}

# Create the bucket only if it does not exist
resource "google_storage_bucket" "tf_state" {
  count = length(data.google_storage_bucket.existing) == 0 ? 1 : 0  # Create if the bucket does not exist

  name     = "tf-gcp-wif-tfstate"  # Your bucket name
  location = "US"  # Set your desired location
}

# Output the bucket name (if created)
output "bucket_name" {
  value = length(data.google_storage_bucket.existing) == 0 ? google_storage_bucket.tf_state[0].name : data.google_storage_bucket.existing.name
}
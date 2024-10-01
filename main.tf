resource "google_storage_bucket" "my-tf-gcp-wif-bucket-01" {
  name          = "tf-gcp-wif-001"
  location      = "us-central1"
  project = "tf-gcp-wif"
  force_destroy = true
  public_access_prevention = "enforced"
}

resource "google_storage_bucket" "my-tf-gcp-wif-bucket-02" {
  name          = "tf-gcp-wif-002"
  location      = "us-central1"
  project = "tf-gcp-wif"
  force_destroy = true
  public_access_prevention = "enforced"
}

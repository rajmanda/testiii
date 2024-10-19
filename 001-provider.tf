provider "google" {
  project = "properties-app-418208"
  region  = "us-central1" # Specify the desired region
}

terraform {
  backend "gcs" {
    bucket = "tf-gcp-wif-tfstate"
    prefix = "terraform/state"  # Static prefix
  }
}
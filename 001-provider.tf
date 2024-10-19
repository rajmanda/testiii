provider "google" {
  project = "properties-app-418208"
  region  = "us-central1" # Specify the desired region
}

terraform {
  backend "gcs" {
    bucket  = "tf-gcp-wif-tfstate"
    prefix  = "terraform/state/${terraform.workspace}"  # Uses the current workspace as prefix
  }
}

variable "branch_name" {
  description = "The name of the current git branch"
  type        = string
  default     = "tf-create-gke-cluster"  # Default branch name
}

resource "google_storage_bucket" "tf_state" {
  name     = "tf-gcp-wif-tfstate"
  location = "US"
  versioning {
    enabled = true
  }
}
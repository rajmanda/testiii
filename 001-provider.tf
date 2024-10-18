terraform {
  backend "gcs" {
    bucket  = "tf-gcp-wif-tfstate"
    prefix  = "terraform/state"   # Optional, used for organization within the bucket
  }
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1" # Check for the latest version
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.33.0"
    }
  }
}
provider "google" {
  project = "properties-app-418208"
  region  = "us-central1" # Specify the desired region
}

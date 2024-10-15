provider "google" {
  project = "properties-app-418208"
  region  = "us-central1" # Specify the desired region
}

terraform {
  backend "gcs" {
    bucket  = "tf-gcp-wif-tfstate"
    prefix  = "terraform/state"   # Optional, used for organization within the bucket
  }
}

provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                    = google_container_cluster.primary.endpoint
    cluster_ca_certificate  = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    token                   = data.google_client_config.default.access_token
  }
}

data "google_client_config" "default" {}

# This is the only manual step that you may have to do to create the tfstate bucket with object versioning. 
 
terraform {
 backend "gcs" {
   bucket  = "tf-gcp-wif-tfstate"
   prefix  = "tf/state"
 }
}

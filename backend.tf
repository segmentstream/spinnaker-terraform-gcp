terraform {
  backend "gcs" {
    bucket = "terraform-spinnaker-state"
  }
}


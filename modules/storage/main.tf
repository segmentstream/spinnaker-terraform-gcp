resource "google_storage_bucket" "spinnaker_state_bucket" {
  name = "${var.bucket_name}"
  location = "${var.bucket_location}"
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_storage_bucket_iam_member" "spinnaker_state_bucket_member" {
  bucket = "${google_storage_bucket.spinnaker_state_bucket.name}"
  role = "roles/storage.admin"
  member = "serviceAccount:${var.spinnaker_service_account_email}"
}
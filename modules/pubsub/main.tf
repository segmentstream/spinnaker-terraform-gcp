resource "google_pubsub_subscription" "cloudbuild" {
  project = "${var.cloudbuild_project}"
  name = "cloudBuildSpinnakerIntegration-cloud-builds"
  topic = "cloud-builds"
}

resource "google_pubsub_subscription_iam_member" "cloudbuild_subscriber" {
  depends_on = ["google_pubsub_subscription.cloudbuild"]
  project = "${var.cloudbuild_project}"
  subscription = "${google_pubsub_subscription.cloudbuild.name}"
  role = "roles/pubsub.subscriber"
  member = "serviceAccount:${var.spinnaker_service_account_email}"
}

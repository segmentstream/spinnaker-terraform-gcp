provider "local" {}

# spinnaker service account and credentials
resource "google_service_account" "spinnaker_service_account" {
  account_id   = "spinnaker"
  display_name = "Spinnaker Service Account"
}

resource "google_service_account_key" "spinnaker_service_account" {
  service_account_id = "${google_service_account.spinnaker_service_account.name}"
}

resource "local_file" "spinnaker_credentials" {
  sensitive_content = "${base64decode(google_service_account_key.spinnaker_service_account.private_key)}"
  filename = "secrets/credentials.json"
}

# grant access to all GKE clusters

resource "google_project_iam_member" "kubernetes_engine_admin" {
  count = "${length(var.gke_cluster_projects)}"
  project = "${var.gke_cluster_projects[count.index]}"

  role = "roles/container.admin"
  member = "serviceAccount:${google_service_account.spinnaker_service_account.email}"
}

# access to Container Registry project

resource "google_project_iam_member" "container_registry_object_viewer" {
  project = "${var.docker_registry_project}"
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.spinnaker_service_account.email}"
}


resource "google_project_iam_member" "docker_registry_project_browser" {
  project = "${var.docker_registry_project}"
  role = "roles/browser"
  member = "serviceAccount:${google_service_account.spinnaker_service_account.email}"
}

# access to GCS artifacts

resource "google_project_iam_member" "gcs_artifacts_storage_admin" {
  project = "${var.gcs_artifacts_project}"
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.spinnaker_service_account.email}"
}

# run cloudbuild builds
resource "google_project_iam_member" "cloudbuild" {
  project = "${var.cloudbuild_project}"
  role = "roles/cloudbuild.builds.builder"
  member = "serviceAccount:${google_service_account.spinnaker_service_account.email}"
}

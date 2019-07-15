variable "phase" {
  description = "1. Before halyard spinnaker installation\n2. After halyard spinnaker installation"
}


variable "docker_registry_project" {}

variable "gcs_artifacts_project" {}

variable "cloudbuild_project" {}

variable "domain" {
}

# Cloudflare

variable "cloudflare_email" {}

variable "cloudflare_token" {}

# Docker Registry

variable "docker_registry_address" {}


# GKE config (Kubernetes Cluster)

variable "spinnaker_gke_cluster_name" {}
variable "spinnaker_gke_cluster_project" {}
variable "spinnaker_gke_cluster_zone" {}
variable "spinnaker_gke_cluster_read_roles" {}
variable "spinnaker_gke_cluster_write_roles" {}

variable "gke_cluster_names" {
  type = "list"
}

variable "gke_cluster_zones" {
  type = "list"
}

variable "gke_cluster_projects" {
  type = "list"
}

variable "gke_cluster_read_roles" {
  type = "list"
}

variable "gke_cluster_write_roles" {
  type = "list"
}

variable "spinnaker_gke_master_user" {
  default     = "k8s_admin"
  description = "Username to authenticate with the k8s master"
}

variable "spinnaker_gke_daily_maintenance_start_time" {
  default = "03:00"
}

variable "spinnaker_storage_bucket_location" {
  default = "europe-west1"
}

variable "spinnaker_storage_bucket_name" {}


# Spinnaker config
variable "spinnaker_admin_email" {}

variable "spinnaker_service_account_name" {}

variable "spinnaker_service_account_roles" {
  type = "list"
}

variable "spinnaker_version" {}

# OAuth2 config
variable "oauth2_client_id" {}

variable "oauth2_client_secret" {}

# Slack config
variable "slack_token" {}
variable "slack_bot_name" {}


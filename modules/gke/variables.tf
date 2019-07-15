variable "gke_cluster_name" {}

variable "gke_master_user" {
  description = "Username to authenticate with the k8s master"
}

variable "gke_daily_maintenance_start_time" {}

variable "gke_cluster_zone" {
  description = "GKE cluster zone"
}

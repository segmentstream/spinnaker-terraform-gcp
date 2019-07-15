variable "phase" {}

variable "gke_master_user" {}

variable "gke_master_pass" {}

variable "gke_client_certificate" {}

variable "gke_client_key" {}

variable "gke_cluster_ca_certificate" {}

variable "gke_endpoint" {}

variable "spinnaker_service_account_name" {}

variable "spinnaker_service_account_roles" {
  type = "list"
}

variable "spinnaker_ui_ip" {}

variable "spinnaker_api_ip" {}

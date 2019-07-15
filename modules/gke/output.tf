output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
  description = "Endpoint for accessing the master node"
}

output "gke_master_pass" {
  value = "${random_string.user_password.result}"
  sensitive   = true
  description = "The auto generated GKE master password"
}

output "gke_client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  sensitive = true
}

output "gke_client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
  sensitive = true
}

output "gke_cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

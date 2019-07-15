output "spinnaker_service_account_email" {
  value = "${google_service_account.spinnaker_service_account.email}"
}

output "spinnaker_service_account_credentials" {
  value = "${google_service_account_key.spinnaker_service_account.private_key}"
}
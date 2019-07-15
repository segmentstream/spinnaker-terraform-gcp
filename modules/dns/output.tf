output "spinnaker_ui_ip" {
  value = "${google_compute_address.spinnaker_ui.address}"
}
output "spinnaker_api_ip" {
  value = "${google_compute_address.spinnaker_api.address}"
}

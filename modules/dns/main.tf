provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

# Spinnaker UI
resource "google_compute_address" "spinnaker_ui" {
  name = "global-spinnaker-ui-ip"
}

resource "cloudflare_record" "spinnaker_ui_dns" {
  domain = "${var.cloudflare_zone}"
  name = "spinnaker"
  value = "${google_compute_address.spinnaker_ui.address}"
  type = "A"
  ttl = 1
  proxied = true
}

# Spinnaker API
resource "google_compute_address" "spinnaker_api" {
  name = "global-spinnaker-api-ip"
}

resource "cloudflare_record" "spinnaker_api_dns" {
  domain = "${var.cloudflare_zone}"
  name = "spinnaker-api"
  value = "${google_compute_address.spinnaker_api.address}"
  type = "A"
  ttl = 1
  proxied = true
}

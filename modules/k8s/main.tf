provider "kubernetes" {
  version = "~> 1.3.0"

  host = "${var.gke_endpoint}"
  username = "${var.gke_master_user}"
  password = "${var.gke_master_pass}"

  client_certificate = "${base64decode(var.gke_client_certificate)}"
  client_key= "${base64decode(var.gke_client_key)}"
  cluster_ca_certificate = "${base64decode(var.gke_cluster_ca_certificate)}"

  load_config_file = false
}

resource "kubernetes_pod" "fiat_service_account_setup" {
  count = "${var.phase == 2 ? 1 : 0}"

  metadata {
    name = "fiat-service-account-setup"
    namespace = "spinnaker"
  }

  spec {
    restart_policy = "Never"
    container {
      image = "bash:latest"
      name  = "fiat-service-account-setup"
      command = ["bash", "/scripts/fiat-service-account.sh"]
      volume_mount {
        name = "fiat-service-account-script"
        read_only = true
        mount_path = "/scripts"
      }
      env = [
        {
          name = "GET_HOSTS_FROM"
          value = "dns"
        }
      }
    }
    volume {
      name = "fiat-service-account-script"
      config_map {
        name = "fiat-service-account-script"
        default_mode = 0744
      }
    }
  }
}

data "template_file" "fiat-service-account-script" {
  count = "${var.phase == 2 ? 1 : 0}"

  template = "${file("${path.module}/fiat-service-account.sh")}"
  vars = {
    name = "${var.spinnaker_service_account_name}"
    roles = "${jsonencode(var.spinnaker_service_account_roles)}"
  }
}

resource "kubernetes_config_map" "fiat_service_account_script" {
  count = "${var.phase == 2 ? 1 : 0}"

  metadata {
    name = "fiat-service-account-script"
    namespace = "spinnaker"
  }
  data {
    fiat-service-account.sh = "${data.template_file.fiat-service-account-script.rendered}"
  }
}

resource "kubernetes_service" "spin_deck" {
  count = "${var.phase == 2 ? 1 : 0}"

  metadata {
    labels {
      app = "spin"
      cluster = "spin-deck-public"
    }
    name = "spin-deck-public"
    namespace = "spinnaker"
  }
  spec {
    selector {
      app = "spin"
      cluster = "spin-deck"
    }
    session_affinity = "None"
    type = "LoadBalancer"
    load_balancer_ip = "${var.spinnaker_ui_ip}"
    port {
      port = 80
      protocol = "TCP"
      target_port = 9000
    }
  }
}

resource "kubernetes_service" "spin_gate" {
  count = "${var.phase == 2 ? 1 : 0}"

  metadata {
    labels {
      app = "spin"
      cluster = "spin-gate-public"
    }
    name = "spin-gate-public"
    namespace = "spinnaker"
  }
  spec {
    selector {
      app = "spin"
      cluster = "spin-gate"
    }
    session_affinity = "None"
    type = "LoadBalancer"
    load_balancer_ip = "${var.spinnaker_api_ip}"
    port {
      port = 80
      protocol = "TCP"
      target_port = 8084
    }
  }
}
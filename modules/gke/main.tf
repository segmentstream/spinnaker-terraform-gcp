resource "random_string" "user_password" {
  length = 16
  special = true
}

resource "google_container_cluster" "primary" {
  name = "${var.gke_cluster_name}"
  location = "${var.gke_cluster_zone}"

  ip_allocation_policy {}
  enable_legacy_abac = false

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "${var.gke_daily_maintenance_start_time}"
    }
  }

  master_auth {
    username = "${var.gke_master_user}"
    password = "${random_string.user_password.result}"
  }

  lifecycle {
    prevent_destroy = true
  }

  node_pool {
    initial_node_count = 1

    node_config {
      oauth_scopes = [
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring"
      ]

      tags = ["gke-node"]
      machine_type = "n1-standard-1"
      disk_size_gb = 10
    }

    autoscaling {
      min_node_count = 1
      max_node_count = 10
    }

    management {
      auto_repair = true
      auto_upgrade = true
    }
  }
}
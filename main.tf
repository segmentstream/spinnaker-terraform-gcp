provider "google" {
  version = "~> 2.00"
  project = var.spinnaker_gke_cluster_project
}

module "dns" {
  source           = "./modules/dns"
  cloudflare_email = var.cloudflare_email
  cloudflare_token = var.cloudflare_token
  cloudflare_zone  = var.domain
}

module "iam" {
  source                  = "./modules/iam"
  docker_registry_project = var.docker_registry_project
  gcs_artifacts_project   = var.gcs_artifacts_project
  gke_cluster_projects    = var.gke_cluster_projects
  cloudbuild_project      = var.cloudbuild_project
}

module "gke" {
  source                           = "./modules/gke"
  gke_cluster_name                 = var.spinnaker_gke_cluster_name
  gke_master_user                  = var.spinnaker_gke_master_user
  gke_cluster_zone                 = var.spinnaker_gke_cluster_zone
  gke_daily_maintenance_start_time = var.spinnaker_gke_daily_maintenance_start_time
}

module "storage" {
  source                          = "./modules/storage"
  spinnaker_service_account_email = module.iam.spinnaker_service_account_email
  bucket_name                     = var.spinnaker_storage_bucket_name
  bucket_location                 = var.spinnaker_storage_bucket_location
}

module "k8s" {
  source                          = "./modules/k8s"
  phase                           = var.phase
  gke_master_user                 = var.spinnaker_gke_master_user
  gke_master_pass                 = module.gke.gke_master_pass
  gke_client_certificate          = module.gke.gke_client_certificate
  gke_client_key                  = module.gke.gke_client_key
  gke_cluster_ca_certificate      = module.gke.gke_cluster_ca_certificate
  gke_endpoint                    = module.gke.endpoint
  spinnaker_service_account_name  = var.spinnaker_service_account_name
  spinnaker_service_account_roles = var.spinnaker_service_account_roles
  spinnaker_ui_ip                 = module.dns.spinnaker_ui_ip
  spinnaker_api_ip                = module.dns.spinnaker_api_ip
}

module "pubsub" {
  source                          = "./modules/pubsub"
  cloudbuild_project              = var.cloudbuild_project
  spinnaker_service_account_email = module.iam.spinnaker_service_account_email
}

resource "null_resource" "docker-compose" {
  triggers = {
    dockercompose_sha1 = filesha1("docker-compose.yml")
    dockerfile_sha1    = filesha1("Dockerfile")
    install_sha1       = filesha1("spinnaker-install.sh")
    tfvars_sha1        = filesha1("terraform.tfvars")
  }
  provisioner "local-exec" {
    command = "docker-compose up --build"
    environment = {
      SPINNAKER_VERSION                 = var.spinnaker_version
      SPINNAKER_GKE_CLUSTER_NAME        = var.spinnaker_gke_cluster_name
      SPINNAKER_GKE_CLUSTER_ZONE        = var.spinnaker_gke_cluster_zone
      SPINNAKER_GKE_CLUSTER_PROJECT     = var.spinnaker_gke_cluster_project
      SPINNAKER_GKE_CLUSTER_READ_ROLES  = var.spinnaker_gke_cluster_read_roles
      SPINNAKER_GKE_CLUSTER_WRITE_ROLES = var.spinnaker_gke_cluster_write_roles
      SPINNAKER_STORAGE_BUCKET_NAME     = var.spinnaker_storage_bucket_name
      SPINNAKER_STORAGE_BUCKET_LOCATION = var.spinnaker_storage_bucket_location
      CLOUDBUILD_PROJECT                = var.cloudbuild_project
      ADMIN                             = var.spinnaker_admin_email
      OAUTH2_CLIENT_ID                  = var.oauth2_client_id
      OAUTH2_CLIENT_SECRET              = var.oauth2_client_secret
      GITHUB_ACCESS_TOKEN               = var.github_access_token
      SLACK_TOKEN                       = var.slack_token
      SLACK_BOT_NAME                    = var.slack_bot_name
      DOCKER_REGISTRY_ADDRESS           = var.docker_registry_address
      DOMAIN                            = var.domain
      GKE_CLUSTER_NAMES                 = join("|", var.gke_cluster_names)
      GKE_CLUSTER_ZONES                 = join("|", var.gke_cluster_zones)
      GKE_CLUSTER_PROJECTS              = join("|", var.gke_cluster_projects)
      GKE_CLUSTER_READ_ROLES            = join("|", var.gke_cluster_read_roles)
      GKE_CLUSTER_WRITE_ROLES           = join("|", var.gke_cluster_write_roles)
    }
  }
}


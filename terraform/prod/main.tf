provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

module "network" {
  source = "../modules/network"
  region = var.gcp_region
}

module "artifact" {
  source = "../modules/artifact"
  region = var.gcp_region
}

module "sql" {
  source                    = "../modules/sql"
  region                    = var.gcp_region
  cloud_run_service_account = module.cloudrun.service_account
}

module "cloudrun" {
  source                  = "../modules/cloudrun"
  project_id              = var.gcp_project_id
  region                  = var.gcp_region
  secret_version          = module.sql.secret_version
  secret_id               = module.sql.secret_id
  cloud_sql_instance_name = module.sql.instance_name
}


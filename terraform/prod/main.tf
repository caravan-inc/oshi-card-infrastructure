provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
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

module "storage" {
  source = "../modules/gcs"
  region = var.gcp_region
}

module "redis" {
  source     = "../modules/redis"
  project_id = var.gcp_project_id
  region     = var.gcp_region
}

module "cloudrun" {
  source                  = "../modules/cloudrun"
  project_id              = var.gcp_project_id
  region                  = var.gcp_region
  secret_version          = module.sql.secret_version
  secret_id               = module.sql.secret_id
  cloud_sql_instance_name = module.sql.instance_name
  redis_host              = module.redis.host
  redis_port              = module.redis.port
}


module "logsink" {
  source           = "../modules/logsink"
  project_id       = var.gcp_project_id
  region           = var.gcp_region
  inclusion_filter = "severity>=WARNING"
}

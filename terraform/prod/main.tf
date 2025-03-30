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
  source     = "../modules/artifact"
  region = var.gcp_region
}

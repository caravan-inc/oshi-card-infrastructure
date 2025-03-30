provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = "${var.gcp_region}-a"
}

module "network" {
  source = "../modules/network"
}

module "gce" {
  source     = "../modules/gce"
  network_id = module.network.network_id
}

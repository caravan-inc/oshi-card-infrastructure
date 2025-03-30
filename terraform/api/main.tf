resource "google_project_service" "cloud-resource-manager" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute-service" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"
}

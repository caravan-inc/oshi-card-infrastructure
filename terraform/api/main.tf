resource "google_project_service" "cloud-resource-manager" {
  project = var.gcp_project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "compute-service" {
  project = var.gcp_project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "artifact-registry-service" {
  project = var.gcp_project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud-run-service" {
  project = var.gcp_project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "sql-service" {
  project = var.gcp_project_id
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "secret-manager-service" {
  project = var.gcp_project_id
  service = "secretmanager.googleapis.com"
}

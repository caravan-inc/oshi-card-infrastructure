resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = "oshi-card"
  description   = "docker repository"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "main" {
  name                = "server"
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/oshi-card/server"

      resources {
        limits = {
          "cpu"    = "4"
          "memory" = "16Gi"
        }
        startup_cpu_boost = false
      }
    }
    scaling {
      max_instance_count = 1
    }
  }
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.main.location
  service  = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

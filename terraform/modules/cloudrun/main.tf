resource "google_service_account" "cloud_run" {
  account_id   = "cloud-run"
  display_name = "Service Account for Cloud Run"
}

resource "google_project_iam_member" "firebase" {
  project = var.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_storage_client" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_cloud_run_v2_service" "main" {
  name     = "server"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/oshi-card/server:latest"

      resources {
        limits = {
          "cpu"    = "4"
          "memory" = "16Gi"
        }
        startup_cpu_boost = false
      }

      liveness_probe {
        http_get {
          path = "/healthz"
        }
      }

      env {
        name = "MYSQL_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = var.secret_id
            version = "1"
          }
        }
      }

      env {
        name  = "MYSQL_NET"
        value = "unix"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    scaling {
      max_instance_count = 1
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.cloud_sql_instance_name]
      }
    }
  }

  depends_on = [var.secret_version]
}

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.main.location
  service  = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

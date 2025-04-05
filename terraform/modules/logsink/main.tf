resource "google_logging_project_sink" "to_bucket" {
  project                = var.project_id
  name                   = "bucket-logs"
  destination            = "storage.googleapis.com/${google_storage_bucket.log-bucket.name}"
  filter                 = var.inclusion_filter
  unique_writer_identity = true
}

resource "google_storage_bucket" "log-bucket" {
  name          = "fankey-log-bucket"
  location      = var.region
  force_destroy = true
}

// Promtail

resource "google_logging_project_sink" "main" {
  name                   = "cloud-logs"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.cloud-logs.id}"
  filter                 = var.inclusion_filter
  unique_writer_identity = true
}

resource "google_pubsub_topic_iam_binding" "log-writer" {
  topic = google_pubsub_topic.cloud-logs.name
  role  = "roles/pubsub.publisher"
  members = [
    google_logging_project_sink.main.writer_identity,
  ]
}

resource "google_pubsub_topic" "cloud-logs" {
  name = "cloud-logs"
}

resource "google_pubsub_subscription" "cloud-log-subscription" {
  name  = "cloud-logs"
  topic = google_pubsub_topic.cloud-logs.name
}

resource "google_service_account" "promtail" {
  account_id   = "promtail"
  display_name = "Service Account for Promtail"
}

resource "google_project_iam_member" "log-subscription-client" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.promtail.email}"
}

resource "google_cloud_run_v2_service" "promtail" {
  name     = "promtail"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.promtail.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/oshi-card/promtail:latest"

      ports {
        container_port = 8080
      }

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "SUBSCRIPTION_ID"
        value = google_pubsub_subscription.cloud-log-subscription.id
      }

      env {
        name  = "TARGET_URL"
        value = "https://${google_cloud_run_v2_service.loki.id}.${var.region}.run.app/loki/api/v1/push"
      }

      resources {
        limits = {
          "cpu"    = "4"
          "memory" = "16Gi"
        }
        startup_cpu_boost = false
      }

      liveness_probe {
        http_get {
          path = "/ready"
        }

        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
      }
    }

    scaling {
      max_instance_count = 1
    }
  }
}


// Loki

resource "google_service_account" "loki-sa" {
  account_id   = "loki-sa"
  display_name = "Service Account for Loki"
}

resource "google_cloud_run_v2_service" "loki" {
  name     = "loki"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.loki-sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/oshi-card/loki:latest"

      ports {
        container_port = 8080
      }

      liveness_probe {
        http_get {
          path = "/ready"
        }

        initial_delay_seconds = 300
        timeout_seconds       = 30
        period_seconds        = 10
        failure_threshold     = 3
      }

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

resource "google_storage_bucket" "loki-bucket" {
  name          = "fankey-loki-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_project_iam_member" "loki-bucket-client" {
  project = var.project_id
  role    = "roles/storage.objectUser"
  member  = "serviceAccount:${google_service_account.loki-sa.email}"
}

# 適切なIAMロールを付与されたユーザーのみがアクセスできるようにする
# https://blog.g-gen.co.jp/entry/authentication-for-cloud-run-with-iap
resource "google_cloud_run_service_iam_member" "loki_public_access" {
  location = google_cloud_run_v2_service.loki.location
  service  = google_cloud_run_v2_service.loki.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

// Grafana

resource "google_service_account" "grafana" {
  account_id   = "grafana"
  display_name = "Service Account for Grafana"
}

resource "google_cloud_run_v2_service" "grafana" {
  name     = "grafana"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.grafana.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/oshi-card/grafana:latest"

      ports {
        container_port = 8080
      }

      liveness_probe {
        http_get {
          path = "/api/health"
        }

        initial_delay_seconds = 300
        timeout_seconds       = 30
        period_seconds        = 10
        failure_threshold     = 3
      }

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

# 適切なIAMロールを付与されたユーザーのみがアクセスできるようにする
resource "google_cloud_run_service_iam_member" "grafana_public_access" {
  location = google_cloud_run_v2_service.grafana.location
  service  = google_cloud_run_v2_service.grafana.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

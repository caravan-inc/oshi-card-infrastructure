resource "google_sql_database_instance" "instance" {
  name   = "cloud-run-sql"
  region = var.region

  database_version = "MYSQL_8_0"

  settings {
    edition = "ENTERPRISE"
    tier    = "db-f1-micro"
  }

  deletion_protection = true
}

resource "google_sql_database" "database" {
  name      = "db"
  instance  = google_sql_database_instance.instance.name
  charset   = "utf8mb4"
  collation = "utf8mb4_0900_ai_ci"
}

resource "google_sql_user" "db_user" {
  name     = "user"
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-password"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.db_password.result
}

resource "google_secret_manager_secret_iam_member" "secret_access" {
  secret_id = google_secret_manager_secret.db_password_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_run_service_account}"
}

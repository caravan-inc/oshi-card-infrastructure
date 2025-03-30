output "secret_version" {
  value = google_secret_manager_secret_version.db_password_secret_version
}

output "secret_id" {
  value = google_secret_manager_secret.db_password_secret.secret_id
}

output "instance_name" {
  value = google_sql_database_instance.instance.connection_name
}

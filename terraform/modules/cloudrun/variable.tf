variable "project_id" {
  description = "GCP project id"
}

variable "region" {
  description = "Region"
}

variable "secret_version" {
  description = "DB password secret version"
}

variable "secret_id" {
  description = "DB password secret id"
}

variable "cloud_sql_instance_name" {
  description = "Cloud SQL instance name"
}

variable "redis_host" {
  description = "Redis host"
}

variable "redis_port" {
  description = "Redis port"
}

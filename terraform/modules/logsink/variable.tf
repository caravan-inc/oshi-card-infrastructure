variable "project_id" {
  description = "GCP project id"
}

variable "region" {
  description = "Region"
}

variable "inclusion_filter" {
  type        = string
  default     = "severity>=INFO"
  description = "Optional GCP Logs query which can filter logs being routed to the pub/sub topic and promtail"
}

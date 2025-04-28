resource "google_redis_instance" "redis" {
  name           = "oshi-card-redis"
  tier           = "BASIC"
  memory_size_gb = 2
  region         = var.region
  redis_version  = "REDIS_6_X"
}

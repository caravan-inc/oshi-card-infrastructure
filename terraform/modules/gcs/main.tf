resource "google_storage_bucket" "bucket" {
  name          = "fankey-image-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_iam_binding" "bucket-iam" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

resource "google_compute_backend_bucket" "kubernetes-backend" {
  name        = "kubernetes-backend-bucket"
  description = "Contains kubernetes stuff"
  bucket_name = "${google_storage_bucket.kubernetes_bucket.name}"
  enable_cdn  = true
}

resource "google_storage_bucket" "kubernetes_bucket" {
  name     = "kubernetes-store-bucket"
  location = "EU"
}

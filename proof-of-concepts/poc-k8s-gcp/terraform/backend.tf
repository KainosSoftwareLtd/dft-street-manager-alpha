resource "google_storage_bucket" "kubernetes_bucket" {
  name     = "kubernetes-store-bucket"
  location = "EU"
}

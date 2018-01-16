### OUTPUTS
output "gce-kubernetes-configuration" {
  value = "${google_storage_bucket.kubernetes_bucket.id}"
}

output "gce-kubernetes-self-link" {
  value = "${google_storage_bucket.kubernetes_bucket.self_link}"
}
# output "docker-registries" {
#   value = ["${aws_ecr_repository.dft-streetworks-ux.repository_url}"]
# }

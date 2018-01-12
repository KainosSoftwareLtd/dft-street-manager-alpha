provider "aws" {
  region = "eu-west-2"
}

data "aws_caller_identity" "current" {}


### BUCKETS
resource "aws_s3_bucket" "kubernetes-configuration" {
  bucket        = "${data.aws_caller_identity.current.account_id}-kubernetes-configuration"
  acl           = "private"
  region        = "eu-west-2"
  force_destroy = true

  versioning {
    enabled = true
  }
}

### DOCKER REGISTRY
resource "aws_ecr_repository" "dft-streetworks-ux" {
  name = "dft-streetworks-ux"
}

### OUTPUTS
output "s3-kubernetes-configuration" {
  value = "${aws_s3_bucket.kubernetes-configuration.id}"
}

output "docker-registries" {
  value = ["${aws_ecr_repository.dft-streetworks-ux.repository_url}"]
}

# Use GOOGLE_CREDENTIALS env variable to point to auth json file

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  zone        = "${var.region_zone}"
}

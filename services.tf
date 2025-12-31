locals {
  required_apis = [
    "compute",
    "container",
    "iam"
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.required_apis)
  project  = var.project_id
  service  = "${each.value}.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_on_destroy = false
}


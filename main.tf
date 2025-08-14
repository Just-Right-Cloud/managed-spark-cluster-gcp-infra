resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_container_cluster" "main" {
  name     = "spark-cluster"
  location = "asia-south1"

  enable_autopilot   = true
  initial_node_count = 2
}

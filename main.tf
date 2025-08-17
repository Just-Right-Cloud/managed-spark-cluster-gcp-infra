resource "google_container_cluster" "main" {
  depends_on = [ google_project_service.project, module.network ]
  name     = "spark-cluster"
  location = var.location

  enable_autopilot   = true
  initial_node_count = 2
}

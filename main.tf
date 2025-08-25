resource "google_container_cluster" "main" {
  name     = "spark-cluster"
  location = var.location

  enable_autopilot   = true
  initial_node_count = 1

  depends_on = [google_project_service.project, module.network]
}

resource "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }

  depends_on = [google_container_cluster.main]
}

resource "helm_release" "argo" {
  name       = "argo"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  version    = "8.3.0"

  set = [
    {
      name  = "server.extraArgs"
      value = "--auth-mode=server"
    },
    {
      name  = "server.ingress.enabled"
      value = "false"
    },
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    }
  ]


  depends_on = [kubernetes_namespace.argo]
}

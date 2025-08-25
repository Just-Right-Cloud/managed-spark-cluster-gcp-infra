resource "google_container_cluster" "main" {
  name     = "spark-cluster"
  location = var.location

  enable_autopilot    = true
  initial_node_count  = 1
  deletion_protection = false

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
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  version    = "8.3.0"

  values = [
    file("${path.module}/argo-values.yaml")
  ]

  depends_on = [kubernetes_namespace.argo]
}

// for some reason, Hashi expects to be able to contact the API to check types resolution
// so the cluster needs to be created before we can apply manifests, or need to use gavibunney/kubectl provider
#resource "kubernetes_manifest" "app_of_apps" {
#  manifest = yamldecode(file("${path.module}/manifests/app_of_apps.yaml"))
#
#  depends_on = [helm_release.argo]
#}

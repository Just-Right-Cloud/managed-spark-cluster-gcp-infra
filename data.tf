data "cloudflare_zones" "main" {
  name   = var.dns_zone_name
  status = "active"
}

data "kubernetes_service" "argo_server" {
  metadata {
    name      = "${helm_release.argo.name}-argocd-server"
    namespace = kubernetes_namespace.argo.metadata[0].name
  }
}

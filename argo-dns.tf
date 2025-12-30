data "kubernetes_service" "argo_server" {
  metadata {
    name      = "argo-argocd-server"
    namespace = "argocd"
  }

  depends_on = [helm_release.argo]
}

resource "cloudflare_dns_record" "argo_cd" {
  zone_id = data.cloudflare_zones.main.result[0].id
  name    = "argo-public"
  comment = "Argo CD Server Load Balancer"
  content = data.kubernetes_service.argo_server.status[0].load_balancer[0].ingress[0].ip
  type    = "A"
  ttl     = 300
}

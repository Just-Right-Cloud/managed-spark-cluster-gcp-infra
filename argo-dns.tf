data "kubernetes_service" "argo_server" {
  metadata {
    name      = "argo-server"
    namespace = "argo"
  }
}

resource "cloudflare_dns_record" "argo_cd" {
  zone_id = data.cloudflare_zones.main.result.id
  name    = "argo-public"
  comment = "Argo CD Server Load Balancer"
  content = data.kubernetes_service.argo_server.status[0].load_balancer[0].ingress[0].ip
  type    = "A"
  ttl     = 300
}

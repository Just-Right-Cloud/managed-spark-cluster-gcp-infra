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
}

#data "http" "argo_crds" {
#  url = "https://github.com/argoproj/argo-cd/tree/master/manifests/crds"
#}

data "http" "argo_operator" {
  url = "https://github.com/argoproj/argo-cd/blob/master/manifests/install.yaml"
}

#resource "kubernetes_manifest" "argo_crds" {
#  for_each   = toset(provider::kubernetes::manifest_decode_multi(file(data.http.argo_crds.response_body)))
#  manifest   = each.value
#  depends_on = [kubernetes_namespace.argo]
#}

resource "kubernetes_manifest" "argo_operator" {
  for_each   = toset(provider::kubernetes::manifest_decode_multi(tostring(data.http.argo_operator.response_body)))
  manifest   = each.value
  depends_on = [kubernetes_namespace.argo]
}

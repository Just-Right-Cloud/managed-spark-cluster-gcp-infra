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
    name = "argocd"
  }

  timeouts {
    delete = "20m"
  }

  depends_on = [google_container_cluster.main]
}

// needs rbac on cluster ahead of time
// gave the backend service account cluster-developer role
resource "helm_release" "argo" {
  name       = "argo"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argo.metadata[0].name
  version    = "9.2.3"

  values = [
    file("${path.module}/argo-values.yaml")
  ]

  #  set = [{
  #    name  = "configs.cm.dex.config"
  #    value = <<EOF
  #    connectors:
  #      - config:
  #          issuer: https://accounts.google.com
  #          clientID: ${google_iam_oauth_client.argocd.oauth_client_id}
  #          clientSecret: ${google_iam_oauth_client_credential.argocd.client_secret}
  #        type: oidc
  #        id: google
  #        name: Google
  #    EOF
  #    }
  #  ]

  depends_on = [kubernetes_namespace.argo]
}

resource "helm_release" "argo_app_of_apps_bootstrap" {
  name      = "argo-app-of-apps-bootstrap"
  chart     = "${path.module}/charts/argo-bootstrap"
  namespace = kubernetes_namespace.argo.metadata[0].name

  set = [{
    name  = "githubRepositoryName"
    value = var.github_repository_name
    },
    {
      name  = "githubApplicationId"
      value = var.github_application_id
    },
    {
      name  = "githubApplicationInstallationId"
      value = var.github_application_installation_id
    }
  ]
  set_sensitive = [{
    name  = "githubApplicationPrivateKey"
    value = var.github_application_private_key
  }]

  depends_on = [helm_release.argo]
}


// for some reason, Hashi expects to be able to contact the API to check types resolution
// so the cluster needs to be created before we can apply manifests, or need to use gavibunney/kubectl provider
#resource "kubernetes_manifest" "app_of_apps" {
#  manifest = yamldecode(file("${path.module}/manifests/app_of_apps.yaml"))
#
#  depends_on = [helm_release.argo]
#}

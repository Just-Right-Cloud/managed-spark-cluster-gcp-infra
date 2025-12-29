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
  version    = "8.3.0"

  values = [
    file("${path.module}/argo-values.yaml")
  ]

  depends_on = [kubernetes_namespace.argo]
}

resource "kubernetes_manifest" "argo_repo_secret" {
  manifest = yamldecode(<<EOF
apiVersion: v1
kind: Secret
metadata:
  name: private-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: "https://github.com/${var.github_repository_name}.git"
  name: private-argo-repo
  project: default
  githubAppId: "${var.github_application_id}"
  githubAppInstallationId: "${var.github_application_installation_id}"
  githubAppPrivateKey: "${var.github_application_private_key}"
EOF
  )

  depends_on = [helm_release.argo]
}

resource "kubernetes_manifest" "app_of_apps" {
  manifest = yamldecode(<<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: "https://github.com/${var.github_repository_name}.git"
    targetRevision: HEAD
    path: Applications/
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
  )
  depends_on = [kubernetes_manifest.argo_repo_secret]
}

// for some reason, Hashi expects to be able to contact the API to check types resolution
// so the cluster needs to be created before we can apply manifests, or need to use gavibunney/kubectl provider
#resource "kubernetes_manifest" "app_of_apps" {
#  manifest = yamldecode(file("${path.module}/manifests/app_of_apps.yaml"))
#
#  depends_on = [helm_release.argo]
#}

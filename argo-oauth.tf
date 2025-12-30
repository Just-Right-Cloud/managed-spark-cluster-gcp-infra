resource "google_iam_oauth_client" "argocd" {
  oauth_client_id       = "argocd"
  location              = var.location
  display_name          = "Argo CD OAuth Client"
  allowed_redirect_uris = ["https://${var.domain_name}.${var.dns_zone_name}/api/dex/callback"]
  allowed_scopes        = ["openid"]
  allowed_grant_types = [
    "authorization_code",
    "refresh_token",
  ]
}

resource "google_iam_oauth_client_credential" "argocd" {
  oauthclient                = google_iam_oauth_client.argocd.oauth_client_id
  location                   = google_iam_oauth_client.argocd.location
  oauth_client_credential_id = "argocd-credential"
  display_name               = "Argo CD OAuth Client Credential"
}

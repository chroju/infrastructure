resource "random_password" "bitwarden_tunnel_secret" {
  length  = 32
  special = false
}

resource "cloudflare_argo_tunnel" "bitwarden_zero_trust_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "bitwarden_zero_trust_tunnel"
  secret     = random_password.bitwarden_tunnel_secret.result
}

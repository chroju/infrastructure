resource "random_password" "tunnel_secret" {
  length  = 32
  special = false
}

resource "cloudflare_argo_tunnel" "k3s_zero_trust_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "k3s_zero_trust_tunnel"
  secret     = random_password.tunnel_secret.result
}

# resource "cloudflare_tunnel_route" "k3s_zero_trust_tunnel_ipv4" {
#   account_id = var.cloudflare_account_id
#   tunnel_id  = cloudflare_argo_tunnel.k3s_zero_trust_tunnel.id
#   network    = "${aws_spot_instance_request.k3s.private_ip}/32"
#   comment    = "Kubernetes API Server (IPv4)"
# }

resource "random_password" "argo_cd_tunnel_secret" {
  length  = 32
  special = false
}

resource "cloudflare_argo_tunnel" "argo_cd_zero_trust_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "argo_cd_tunnel"
  secret     = random_password.argo_cd_tunnel_secret.result
}

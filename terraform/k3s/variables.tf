variable "cloudflare_api_token" {}
variable "cloudflare_account_id" {}
variable "cloudflare_tunnel_kubectl_hostname" {}
variable "cloudflare_tunnel_argo_cd_hostname" {}
variable "cost_anomaly_email" {
  type      = string
  sensitive = true
}

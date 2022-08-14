resource "aws_ssm_parameter" "kubectl_tunnel_secret" {
  name  = "/chroju/k3s/kubectl_tunnel_secret"
  type  = "SecureString"
  value = random_password.tunnel_secret.result
}

resource "aws_ssm_parameter" "argo_cd_tunnel_secret" {
  name  = "/chroju/k3s/argo_cd_tunnel_secret"
  type  = "SecureString"
  value = random_password.argo_cd_tunnel_secret.result
}

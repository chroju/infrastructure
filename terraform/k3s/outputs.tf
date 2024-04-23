# output "k3s_instance_id" {
#   value = aws_autoscaling_group.k3s.ins
# }

output "prometheus_endpoint" {
  value = aws_prometheus_workspace.k3s.prometheus_endpoint
}

output "k3s_instance_id" {
  value = aws_spot_instance_request.k3s.spot_instance_id
}

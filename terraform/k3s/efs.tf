resource "aws_efs_file_system" "k3s" {
  creation_token = "k3s"
  encrypted      = true
  kms_key_id     = aws_kms_key.k3s.arn

  tags = {
    "Name" = "k3s"
  }
}

resource "aws_efs_mount_target" "k3s" {
  file_system_id  = aws_efs_file_system.k3s.id
  subnet_id       = data.aws_subnet.public.id
  security_groups = [aws_security_group.efs_k3s.id]
}

resource "aws_efs_mount_target" "k3s_c" {
  file_system_id  = aws_efs_file_system.k3s.id
  subnet_id       = data.aws_subnet.public_c.id
  security_groups = [aws_security_group.efs_k3s.id]
}

data "aws_vpc" "dev" {
  id = "vpc-7f17bc1a"
}

resource "aws_security_group" "efs_k3s" {
  vpc_id = data.aws_vpc.dev.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [data.aws_security_group.external_only.id]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = ["public-d"]
  }
}

data "aws_ami" "ubuntu_22_04_latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_ec2_spot_price" "for_k3s" {
  instance_type     = local.k3s_instance_type
  availability_zone = data.aws_subnet.public.availability_zone

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}

data "aws_security_group" "external_only" {
  name = "external_only"
}

resource "aws_spot_instance_request" "k3s" {
  ami                         = data.aws_ami.ubuntu_22_04_latest.id
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.public.id
  iam_instance_profile        = "AmazonEC2RoleforSSM" # TODO
  key_name                    = "chiang"              # TODO
  vpc_security_group_ids      = [data.aws_security_group.external_only.id]

  disable_api_termination = true

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
    # encrypted   = true
    # kms_key_id  = aws_kms_alias.k3s.id
  }

  # user_data = <<-EOF
  # #!/bin/bash
  # curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -
  # EOF

  # spot instance
  spot_price = data.aws_ec2_spot_price.for_k3s.spot_price * 1.1 # max price

  instance_type                        = local.k3s_instance_type
  instance_initiated_shutdown_behavior = "stop"
}

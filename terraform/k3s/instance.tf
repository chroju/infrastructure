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

  user_data = templatefile("${path.module}/k3s_user_data_template.sh",
    {
      k3s_version           = local.k3s_version,
      cloudflared_version   = local.cloudflared_version,
      cloudflare_account_id = var.cloudflare_account_id,
      cloudflare_tunnel = {
        kubectl = {
          id       = cloudflare_argo_tunnel.k3s_zero_trust_tunnel.id,
          secret   = random_password.tunnel_secret.result,
          hostname = var.cloudflare_tunnel_kubectl_hostname,
        }
        argo_cd = {
          id       = cloudflare_argo_tunnel.argo_cd_zero_trust_tunnel.id,
          secret   = random_password.argo_cd_tunnel_secret.result,
          hostname = var.cloudflare_tunnel_argo_cd_hostname,
        }
      }
    }
  )

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
    # encrypted   = true
    # kms_key_id  = aws_kms_alias.k3s.id
  }

  # spot instance
  spot_price = data.aws_ec2_spot_price.for_k3s.spot_price * 1.1 # max price

  instance_type                        = local.k3s_instance_type
  instance_initiated_shutdown_behavior = "stop"
  wait_for_fulfillment                 = true

  tags = {
    "Name" = "k3s-zero-trust"
  }
}

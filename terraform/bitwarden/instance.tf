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

data "aws_ec2_spot_price" "for_bitwarden" {
  instance_type     = local.bitwarden_instance_type
  availability_zone = data.aws_subnet.public.availability_zone

  filter {
    name   = "product-description"
    values = ["Linux/UNIX"]
  }
}

data "aws_security_group" "external_only" {
  name = "external_only"
}

data "aws_pricing_product" "ec2_instance" {
  provider     = aws.ap-south-1
  service_code = "AmazonEC2"
  filters {
    field = "instanceType"
    value = local.bitwarden_instance_type
  }
  filters {
    field = "operatingSystem"
    value = "Linux"
  }
  filters {
    field = "preInstalledSw"
    value = "NA"
  }
  filters {
    field = "location"
    value = "Asia Pacific (Tokyo)"
  }
  filters {
    field = "licenseModel"
    value = "No License required"
  }
  filters {
    field = "tenancy"
    value = "Shared"
  }
  filters {
    field = "capacitystatus"
    value = "Used"
  }
}

resource "aws_spot_instance_request" "bitwarden" {
  ami                         = data.aws_ami.ubuntu_22_04_latest.id
  associate_public_ip_address = true
  subnet_id                   = data.aws_subnet.public.id
  iam_instance_profile        = aws_iam_instance_profile.bitwarden_role.name
  key_name                    = "chiang" # TODO
  vpc_security_group_ids      = [data.aws_security_group.external_only.id]

  disable_api_termination = true

  user_data = templatefile("${path.module}/bitwarden_user_data_template.sh",
    {
      ebs_volume_id         = aws_ebs_volume.bitwarden_data.id,
      cloudflared_version   = local.cloudflared_version,
      cloudflare_account_id = var.cloudflare_account_id,
      cloudflare_tunnel = {
        bitwarden = {
          id       = cloudflare_argo_tunnel.bitwarden_zero_trust_tunnel.id,
          secret   = random_password.bitwarden_tunnel_secret.result,
          hostname = var.cloudflare_tunnel_bitwarden_hostname,
        }
      }
      mackerel_api_key = var.mackerel_api_key,
    }
  )

  root_block_device {
    volume_size = 35
    volume_type = "gp3"
    # encrypted   = true
    # kms_key_id  = aws_kms_alias.k3s.id
  }

  # spot instance
  spot_price = values(values(jsondecode(data.aws_pricing_product.ec2_instance.result).terms.OnDemand)[0].priceDimensions)[0].pricePerUnit.USD * 0.9

  instance_type                        = local.bitwarden_instance_type
  instance_initiated_shutdown_behavior = "stop"
  wait_for_fulfillment                 = true

  tags = {
    "Name" = "bitwarden-zero-trust"
  }
}

resource "aws_ebs_volume" "bitwarden_data" {
  availability_zone = "ap-northeast-1d"
  size              = 10
  encrypted         = true
  kms_key_id        = aws_kms_key.bitwarden.arn
  type              = "gp3"

  tags = {
    Name = "bitwarden_data"
  }
}

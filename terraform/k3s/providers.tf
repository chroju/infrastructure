terraform {
  required_version = "1.7.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.1.0"
    }
  }

  backend "remote" {
    organization = "chroju"
    workspaces {
      name = "k3s"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Workspace = "k3s"
    }
  }
}

provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token # TODO
}

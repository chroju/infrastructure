terraform {
  required_version = "1.2.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.28.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.22.0"
    }
  }

  backend "remote" {
    organization = "chroju"
    workspaces {
      name = "bitwarden"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Workspace = "bitwarden"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token # TODO
}

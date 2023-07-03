terraform {
  required_version = "1.3.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.9.0"
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

provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token # TODO
}

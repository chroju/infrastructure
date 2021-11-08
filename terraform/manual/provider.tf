terraform {
  required_version = "1.0.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.63.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "chroju"

    workspaces {
      name = "chroju-infrastructure-manual"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      GitHubOrg          = "infrastructure"
      TerraformWorkspace = "chroju-infrastructure-manual"
    }
  }
}

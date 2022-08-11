terraform {
  required_version = "1.2.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
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

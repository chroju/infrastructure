terraform {
  required_version = "1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.0"
    }
  }

  backend "remote" {
    organization = "chroju"
    workspaces {
      name = "test-b"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

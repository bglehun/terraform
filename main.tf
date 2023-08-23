terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  backend "s3" {
    bucket         = "terraform-tfstate"
    key            = "chat-server/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-tfstate-lock"
  }
}

provider "aws" {
  region = "ap-northeast-2"

  default_tags {
    tags = {
      Name = var.app_name
    }
  }
}

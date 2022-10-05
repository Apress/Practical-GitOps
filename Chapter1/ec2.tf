terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  profile = "gitops"
  region  = "us-east-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-00399ec92321828f5"
  instance_type = "t2.micro"
  tags = {
    env = "test"
  }
}
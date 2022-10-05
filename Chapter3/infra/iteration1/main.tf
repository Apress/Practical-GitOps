# Setting and locking the Dependencies
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.10"
    }
  }

  required_version = ">= 1.1.0"
}

# AWS Provider configuration
provider "aws" {
  region = "us-east-2"
}

# AWS EC2 Resource creation
resource "aws_instance" "apache2_server" {
  ami           = "ami-00399ec92321828f5"
  instance_type = "t2.micro"
  user_data = "${file("user_data.sh")}"
  tags = {
    env = "dev"
  }
}
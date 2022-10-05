# Variable Declaration
variable "environment" {
  description = "The environment e.g uat or prod or dev"
  type        = string
}

variable "region" {
  description = "The region where we wish to deploy to"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

locals {
  name-suffix = "${var.region}-${var.environment}"
}

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
  region = var.region
}

# Data element fetching the AMI ID of Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  # AWS ID of the Canonical organisation
  owners = ["099720109477"]
}

# Creating Security Group with ingress/egress rules
resource "aws_security_group" "public_http_sg" {
  name = "public_http_sg-${local.name-suffix}"

# Allow all inbound traffic to port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow EC2 to be connected from internet
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  tags = {
    "Environment" = var.environment
    "visibility"  = "public"
  }
}

# AWS EC2 Resource creation
resource "aws_instance" "apache2_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.public_http_sg.id]
  user_data = "${file("user_data.sh")}"
  tags = {
    env  = var.environment
    Name = "ec2-${local.name-suffix}"
  }
}

# Output the Public IP Address
output "ip_address" {
  value = aws_instance.apache2_server.public_ip
}
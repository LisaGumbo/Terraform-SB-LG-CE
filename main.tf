terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-1"
}

resource "aws_vpc" "SCL-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "SCL-vpc"
  }
}
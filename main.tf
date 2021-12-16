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
  region = "us-east-1"
}

// Create a variable to define the cidr block 
variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "SCL-vpc" {
  cidr_block = var.cidr_block
  tags = {
      Name = "SCL-vpc"
  }
}

// Create a public subnet
resource "aws_subnet" "SCL-public-subnet" {
  vpc_id     = aws_vpc.SCL-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "SCL-public-subnet"
  }
}

// Create a private subnet
resource "aws_subnet" "SCL-private-subnet" {
  vpc_id     = aws_vpc.SCL-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "SCL-private-subnet"
  }
}

resource "aws_internet_gateway" "SCL-prod-igw" {
  vpc_id = aws_vpc.SCL-vpc.id
  tags = {
      Name = "SCL-prod-igw"
    }
}

resource "aws_route_table" "SCL-prod-public-routetable" {
    vpc_id = aws_vpc.SCL-vpc.id
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.SCL-prod-igw.id
    }
    tags = {
        Name = "SCL-prod-public-routetable"
    }
}

resource "aws_route_table_association" "SCL-prod-crta-public-subnet"{
    subnet_id = aws_subnet.SCL-public-subnet.id
    route_table_id = aws_route_table.SCL-prod-public-routetable.id
}

resource "aws_security_group" "SCL-ssh-allowed-frontend" {
    vpc_id = aws_vpc.SCL-vpc.id
    
    // HTTP: 80, SSH: 22 from 0.0.0.0/0
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
     egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "SCL-ssh-allowed-frontend"
    }
}








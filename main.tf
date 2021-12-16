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

resource "aws_security_group" "SCL-ssh-allowed-MongoDB" {
    vpc_id = aws_vpc.SCL-vpc.id
    
    // Mongo-Express Port: 27017  0.0.0.0/0
    ingress {
        from_port = 27017
        to_port = 27017
        protocol = "tcp"
        // This means, all ip address are allowed to ssh ! 
        // Do not do it in the production. 
        // Put your office or home address in it!
        cidr_blocks = ["0.0.0.0/0"]
    }
    //If you do not add this rule, you can not reach the NGIX  
    ingress {
        from_port = 5000
        to_port = 5000
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
        Name = "SCL-ssh-allowed-MongoDB"
    }
}


resource "aws_security_group" "SCL-ssh-allowed-backend" {
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
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 27017
        to_port = 27017
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


resource "aws_instance" "SCL-EC2-web" {
    ami = "ami-0ed9277fb7eb570c9"
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.SCL-public-subnet.id
    # Security Group
    vpc_security_group_ids = [aws_security_group.SCL-ssh-allowed-frontend.id]
    # the Public SSH key
    # key_name = "lisagumbo-ec2-keypair"
    #key_name = "christianKeyPair12-9-1"
    key_name = "SB-EC2-Excercise"
    tags = {
        Name = "SCL-EC2-web"
    }
    //user_data = "${file("frontend.sh")}"
}

resource "aws_instance" "SCL-EC2-MongoDB" {
    ami = "ami-0ed9277fb7eb570c9"
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.SCL-private-subnet.id
    # Security Group
    vpc_security_group_ids = [aws_security_group.SCL-ssh-allowed-MongoDB.id]
    # the Public SSH key
    # key_name = "lisagumbo-ec2-keypair"
    #key_name = "christianKeyPair12-9-1"
    key_name = "SB-EC2-Excercise"
    tags = {
        Name = "SCL-EC2-MongoDB"
    }
    //user_data = "${file("MongoDB.sh")}"
}

resource "aws_instance" "SCL-EC2-backend" {
    ami = "ami-0ed9277fb7eb570c9"
    instance_type = "t2.micro"
    # VPC
    subnet_id = aws_subnet.SCL-private-subnet.id
    # Security Group
    vpc_security_group_ids = [aws_security_group.SCL-ssh-allowed-backend.id]
    # the Public SSH key
    # key_name = "lisagumbo-ec2-keypair"
    #key_name = "christianKeyPair12-9-1"
    key_name = "SB-EC2-Excercise"
    tags = {
        Name = "SCL-EC2-backend"
    }
    //user_data = "${file("MongoDB.sh")}"
}

output "SCL-subnet_id" {
  value = aws_subnet.SCL-public-subnet.id
}








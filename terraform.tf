provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "ap-northeast-1"
}

resource aws_key_pair "deploy" {
  key_name = "deploy-key"
  public_key = "${var.aws_pubkey}"
}

### VPC Setup ###

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Public subnets
resource "aws_subnet" "ap-northeast-1a-public" {
  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

# Routing table for public subnets
resource "aws_route_table" "ap-northeast-1-public" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }
}

resource "aws_route_table_association" "ap-northeast-1-public" {
  subnet_id = "${aws_subnet.ap-northeast-1a-public.id}"
  route_table_id = "${aws_route_table.ap-northeast-1-public.id}"
}

### Begin Application Stack Setup ###

# Base Security Group
resource "aws_security_group" "base" {
  name = "base"
  description = "Base group for all servers"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 0  
    to_port = 0 
    protocol = -1
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"
}

# HTTP Ingress
resource "aws_security_group" "inbound_http" {
  name = "inbound_http"
  description = "Allow HTTP traffic from the internet"

  ingress {
    from_port = 80 
    to_port = 80 
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"
}

# Create Cluster Servers
resource "aws_instance" "app1" {
  connection {
    user = "ubuntu"
  }
  instance_type = "t2.micro"
  tags {
    Name = "app1"
    Group = "application"
  }
  vpc_security_group_ids = [
    "${aws_security_group.base.id}",
    "${aws_security_group.inbound_http.id}"
  ]
  subnet_id = "${aws_subnet.ap-northeast-1a-public.id}"
  ami = "${var.aws_ubuntu_ami}"
  key_name = "${aws_key_pair.deploy.key_name}"
}

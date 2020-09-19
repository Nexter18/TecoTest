provider "aws" {
  region = "us-west-1"
}

# Declare the data source
data "aws_availability_zones" "available" {}

# VPC Creation
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_range_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "teco_test_tf_vpc"
  }
}

# Creating Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "teco_test_tf_igw"
  }
}

# Creating Route Table
resource "aws_route_table" "r" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "teco_test_tf_rt"
  }
}

# Creating Subnet
resource "aws_subnet" "public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    name = "teco_test_tf_subnet-${count.index + 1}"
  }
}

# Subnet Route Table Asociation

resource "aws_route_table_association" "a" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.r.id
  depends_on     = [aws_route_table.r, aws_subnet.public_subnet]
}

# Security Group

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "teco_test_tf_secgroup"
  }
}
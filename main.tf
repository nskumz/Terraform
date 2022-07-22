# provider aws
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
# Create a VPC
resource "aws_vpc" "task-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "kumars"
  }
}
# creating Public Subnet1
resource "aws_subnet" "pub_subnet1" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "PUB-SB1"
  }
}
# creating Public Subnet2
resource "aws_subnet" "pub_subnet2" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "PUB-SB2"
  }
}
# creating private Subnet1
resource "aws_subnet" "pvt_subnet1" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "PVT-SB1"
  }
}
# creating private Subnet2
resource "aws_subnet" "pvt_subnet2" {
  vpc_id                  = aws_vpc.task-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "PVT-SB2"
  }
}
# creating  Internet Gateway
resource "aws_internet_gateway" "kumars_igw" {
  vpc_id = aws_vpc.task-vpc.id
  tags = {
    Name = "IGW"
  }
}
# creating Public Route Table
resource "aws_route_table" "kumars_pub_rt" {
  vpc_id = aws_vpc.task-vpc.id
  tags = {
    Name = "PUB-RT"
  }
}
output "aws_route_table_public_ids" {
  value = aws_route_table.kumars_pub_rt.id
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.kumars_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kumars_igw.id
}
# Private Route Table
# Default is private 
resource "aws_route_table" "kumars_pvt_rt" {
  vpc_id = aws_vpc.task-vpc.id
  tags = {
    Name = "PVT-RT"
  }
}
# Public Route Table Association
resource "aws_route_table_association" "kumars_pub_assoc" {
  subnet_id      = aws_subnet.pub_subnet1.id
  route_table_id = aws_route_table.kumars_pub_rt.id
}
# Private Route Table Association
resource "aws_route_table_association" "kumars_pvt_assoc" {
  subnet_id      = aws_subnet.pvt_subnet1.id
  route_table_id = aws_route_table.kumars_pvt_rt.id
}
#kumars Security Group
resource "aws_security_group" "kumars_sg" {
  name        = "allow_sshhttp"
  description = "Allow sshhttp inbound traffic"
  vpc_id      = aws_vpc.task-vpc.id
  ingress {
    description = "ssh from everywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http from everywhere"
    from_port   = 80
    to_port     = 80
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
    Name = "allow_sshhttp"
  }
}
# creating  Instance
resource "aws_instance" "centos7_instance" {
  ami                    = "ami-02358d9f5245918a3"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.pub_subnet1.id
  key_name               = "devops"
  count                  = 2
  vpc_security_group_ids = [aws_security_group.kumars_sg.id]
  user_data              = file("data.sh")

  tags = {
    name = "task_instance"
  }
}




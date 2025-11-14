terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 기존 키 페어 삭제
resource "null_resource" "delete_key_pair" {
  provisioner "local-exec" {
    command = "aws ec2 delete-key-pair --key-name sb3-security-key --region ap-northeast-2 || true"
  }
}

# TLS 키 페어 생성
resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096

  depends_on = [null_resource.delete_key_pair]
}

# AWS 키 페어
resource "aws_key_pair" "deployer" {
  key_name   = "sb3-security-key"
  public_key = tls_private_key.deployer.public_key_openssh

  depends_on = [null_resource.delete_key_pair]
}

# VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "SB3-Security-VPC"
  }
}

# 서브넷 생성
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "SB3-Security-Public-Subnet"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "SB3-Security-IGW"
  }
}

# 라우트 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "SB3-Security-Public-RT"
  }
}

# 라우트 테이블 연결
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 보안 그룹
resource "aws_security_group" "ec2" {
  name        = "SB3-Security-SG"
  description = "Security group for SB3 Security application"
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
    Name = "SB3-Security-SG"
  }
}

# EC2 인스턴스
resource "aws_instance" "app" {
  ami                    = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2023
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "SB3-Security-Instance"
  }
}

# 출력값
output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_instance.app.public_ip
}

output "private_key" {
  value     = tls_private_key.deployer.private_key_pem
  sensitive = true
} 
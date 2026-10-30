terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
  }
  required_version = ">= 1.6"
  backend "s3"{
    bucket = "dogukan-devops-journey"
    key = "09-terraform-aws-ec2/terraform.tfstate"
    region = "eu-north-1"
    use_lockfile = true
  }
}

provider "aws" {
    region = "eu-north-1"

    default_tags {
        tags = {
            Project = "devops-journey"
            ManagedBy = "terraform"
        }
    }
}


data "aws_vpc" "main" {
  tags = {
    Name = "devops-journey-vpc"
  }
}

data "aws_subnet" "public" {
  tags = {
    Name = "devops-journey-public-subnet"
  }
}


output "vpc_output" {
  value = data.aws_vpc.main.id
}

output "subnet_output" {
  value = data.aws_subnet.public.cidr_block
}

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

}

output "ami_id_output"{
    value = data.aws_ami.ubuntu.id
}

output "ami_name_output"{
    value = data.aws_ami.ubuntu.name
}




resource "aws_key_pair" "devops-journey" {
  key_name   = "devops-journey"
  public_key = file("~/.ssh/devops-journey.pub")
}


resource "aws_security_group" "main" {
  name        = "devops-journey-sg"
  description = "Allow SSH from my IP"
  vpc_id      = data.aws_vpc.main.id
  tags = {
    Name = "devops-journey-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}


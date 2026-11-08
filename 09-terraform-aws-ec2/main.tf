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




data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

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

resource "aws_vpc_security_group_ingress_rule" "http"{
  security_group_id = aws_security_group.main.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"
}

resource "aws_instance" "server"{
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    subnet_id = data.aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.main.id]
    key_name = aws_key_pair.devops-journey.key_name
    associate_public_ip_address = true
    
    tags = {
      Name = "devops-journey-server"
    }

    user_data = <<-EOF
      #!/bin/bash
      apt-get update && apt-get install -y nginx
      echo "<h1>Hello World</h1>" > /var/www/html/index.html
    EOF

    user_data_replace_on_change = true
}

output "server_public_ip"{
  value = aws_instance.server.public_ip
}

output "website_url"{
  value = "http://${aws_instance.server.public_ip}"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.71"
    }
  }
  required_version = ">= 1.6"
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

resource "aws_s3_bucket" "journey" {
  bucket = "dogukan-devops-journey"
}
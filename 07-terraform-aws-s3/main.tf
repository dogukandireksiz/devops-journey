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
  lifecycle{
    prevent_destroy = true
  }
}


resource "aws_s3_bucket_versioning" "journey" {
  bucket = aws_s3_bucket.journey.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "journey" {
  bucket = aws_s3_bucket.journey.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
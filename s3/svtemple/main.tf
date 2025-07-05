# Terraform configuration for S3 API Storage bucket
# This file references the S3 module for Python API storage

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-20250701"
    key            = "global/s3/svtemple/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "TerraformStateLock"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Python-API-Storage"
      Environment = var.environment
      client      = var.client
      ManagedBy   = "Terraform"
      BucketName  = "common"
    }
  }
}

# S3 Module for Python API Storage
module "s3_api_storage" {
  source = "../../modules/s3"
  
  bucket_name = var.bucket_name
  environment = var.environment
  enable_versioning = var.enable_versioning
  tags = var.tags
  controlled_by = var.controlled_by
  client = var.client
  create = var.create
  delete = var.delete
} 
# Terraform configuration for website-2 bucket
# This file references the S3 static website module

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
    bucket         = "my-terraform-state-bucket-123456"
    key            = "global/s3/website-2/terraform.tfstate"
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
      Project     = "StaticWebsites"
      Environment = var.environment
      client      = var.client
      ManagedBy   = "Terraform"
      BucketName  = "website-1"
    }
  }
}

# S3 Static Website Module
module "s3_static_website" {
  source = "../../modules/s3-static-website"

  bucket_name = var.bucket_name
  environment = var.environment
  
  index_html_path = "index.html"
  create_error_page = var.create_error_page
  error_html_path = "error.html"
  
  enable_versioning = var.enable_versioning
  enable_cloudfront = var.enable_cloudfront
  cloudfront_price_class = var.cloudfront_price_class
  cloudfront_aliases = var.cloudfront_aliases
  
  tags = var.tags
  controlled_by = var.controlled_by
  client = var.client
} 
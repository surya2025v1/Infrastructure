# Terraform configuration for ECR repository
# This file references the ECR module

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
    key            = "global/ecr/user-api-v1/terraform.tfstate"
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
      Project     = "ECRRepositories"
      Environment = var.environment
      Repository  = var.repository_name
      ManagedBy   = "Terraform"
      Purpose     = "Lambda Function Storage"
    }
  }
}

# ECR Repository Module
module "ecr_repository" {
  source = "../modules/ecr"

  # AWS account and region
  ecr_registry = var.ecr_registry
  ecr_repository = var.repository_name
  
  description = var.service_description
  image_tag_mutability = var.image_tag_mutability
  scan_on_push = var.scan_on_push
  encryption_type = var.encryption_type
  
  # Repository policy allowing GitHub Actions and Lambda access
  repository_policy = var.repository_policy
  
  # Automatic Image Retention Configuration
  max_images = var.max_images
  untagged_image_retention_days = var.untagged_image_retention_days
  enable_automatic_lifecycle_policy = var.enable_automatic_lifecycle_policy
  
  tags = merge(var.tags, {
    Service = var.service_name
    Type    = "Lambda Function Repository"
    Client  = var.client
    controlled_by = var.controlled_by
  })
}
# Simple ECR Repository - Just provide repo name

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

provider "aws" {
  region = var.aws_region
}

module "ecr_repository" {
  source = "../modules/ecr"
  
  repository_name = var.repository_name
  
  tags = {
    Environment = var.environment
    Service     = var.service_name
    Project     = "ECR"
    ManagedBy   = "Terraform"
  }
}
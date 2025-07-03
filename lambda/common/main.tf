# Terraform configuration for FastAPI Lambda function
# This file references the Lambda module

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
    key            = "global/lambda/common/terraform.tfstate"
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
      Project     = "FastAPI-Lambda"
      Environment = var.environment
      client      = var.client
      ManagedBy   = "Terraform"
      FunctionName = "common"
    }
  }
}

# Data source for existing AWS Secrets Manager secret with DB info
data "aws_secretsmanager_secret" "db_credentials" {
  name = var.db_credentials_secret_name
}

# Lambda Module
module "lambda" {
  source                  = "../../modules/lambda"
  function_name           = var.function_name
  environment             = var.environment
  handler                 = var.handler
  runtime                 = var.runtime
  environment_variables   = merge(var.environment_variables, {
    DB_CREDENTIALS_SECRET_ARN = data.aws_secretsmanager_secret.db_credentials.arn
  })
  memory_size             = var.memory_size
  timeout                 = var.timeout
  vpc_subnet_ids          = var.vpc_subnet_ids
  vpc_security_group_ids  = var.vpc_security_group_ids
  role_arn                = var.role_arn
  tags                    = var.tags
  controlled_by           = var.controlled_by
  client                  = var.client
  create                  = var.create
  delete                  = var.delete
  s3_bucket               = var.s3_bucket
  s3_key                  = var.s3_key
  s3_object_version       = var.s3_object_version
}

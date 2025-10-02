# Terraform configuration for API Gateway with multiple Lambda functions
# This file references both the Lambda and API Gateway modules

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
    key            = "global/api-gateway/common/terraform.tfstate"
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
      Project      = "Temple-Project-API-Gateway"
      Environment  = var.environment
      client       = var.client
      ManagedBy    = "Terraform"
      FunctionName = "common"
    }
  }
}

# Data source for existing AWS Secrets Manager secret with DB info
data "aws_secretsmanager_secret" "db_credentials" {
  name = var.db_credentials_secret_name
}

# Security Group for Lambda Functions
resource "aws_security_group" "lambda" {
  name_prefix = "lambda-common-"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  # Outbound to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound to RDS (MySQL)
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.lambda_to_rds_security_groups
  }

  tags = merge(var.tags, {
    Name        = "lambda-common-sg"
    Component   = "Security-Group-Lambda"
    Description = "Lambda function security group for common resources"
  })
}

# Multiple Lambda Functions
module "lambda_functions" {
  source   = "../../modules/lambda"
  for_each = var.lambda_functions

  function_name         = each.value.function_name
  handler               = each.value.handler
  runtime               = each.value.runtime
  environment_variables = each.value.environment_variables
  memory_size           = each.value.memory_size
  timeout               = each.value.timeout
  role_arn              = each.value.role_arn
  tags = merge(var.tags, {
    Component = "Lambda-${each.key}"
  })
  environment       = var.environment
  controlled_by     = var.controlled_by
  client            = var.client
  create            = each.value.create
  delete            = each.value.delete
  s3_bucket         = each.value.s3_bucket
  s3_key            = each.value.s3_key
  s3_object_version = each.value.s3_object_version
  rds_secret_name   = var.rds_secret_name
  
  # VPC Configuration
  vpc_subnet_ids         = each.value.vpc_subnet_ids
  vpc_security_group_ids = [aws_security_group.lambda.id]
  
  # ECR Configuration
  use_ecr_image  = each.value.use_ecr_image
  ecr_image_uri  = each.value.ecr_image_uri
}

# Create map of Lambda function names to their invoke ARNs
locals {
  lambda_function_arns = {
    for k, v in module.lambda_functions : v.lambda_function_name => v.lambda_invoke_arn
  }
}

# API Gateway Module with multiple Lambda integrations
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name              = var.api_gateway_name
  api_description       = var.api_gateway_description
  endpoint_type         = var.api_gateway_endpoint_type
  lambda_integrations   = var.api_gateway_lambda_integrations
  lambda_function_arns  = local.lambda_function_arns
  stage_name            = var.api_gateway_stage_name
  ignore_existing_stage = var.ignore_existing_stage
  authorization_type    = var.api_gateway_authorization_type
  authorizer_id         = var.api_gateway_authorizer_id
  enable_logging        = var.api_gateway_enable_logging
  log_retention_days    = var.api_gateway_log_retention_days
  environment           = var.environment
  client                = var.client
  controlled_by         = var.controlled_by
  create                = var.create_api_gateway
  tags = merge(var.tags, {
    Component = "API-Gateway"
  })

  # Security Configuration
  enable_waf         = var.enable_waf
  enable_usage_plans = var.enable_usage_plans
  enable_monitoring  = var.enable_monitoring

  # CORS Configuration
  cors_origins           = var.cors_origins
  cors_allow_credentials = var.cors_allow_credentials
  cors_allow_methods     = var.cors_allow_methods
  cors_allow_headers     = var.cors_allow_headers
  cors_expose_headers    = var.cors_expose_headers
  cors_max_age           = var.cors_max_age

  # Rate Limiting Configuration
  rate_limit   = var.rate_limit
  burst_limit  = var.burst_limit
  quota_limit  = var.quota_limit
  quota_period = var.quota_period

  # API Keys Configuration
  api_keys = var.api_keys

  # Security Headers Configuration
  security_headers = var.security_headers
}

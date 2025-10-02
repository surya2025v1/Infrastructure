# Public ECR Repository Configuration for Client Applications
# References existing public ECR repository: public.ecr.aws/x7o9n0b1/clients-code
# Provides configuration for Lambda functions to use this public repository

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Public ECR repository information (no data source needed)
locals {
  public_registry_url      = "public.ecr.aws/x7o9n0b1/clients-code"
  repository_name          = "clients-code"
  repository_url           = "public.ecr.aws/x7o9n0b1/clients-code"
  registry_id             = "x7o9n0b1"
  registry_region         = "us-east-1"
}

output "public_ecr_repository_url" {
  description = "Public ECR repository URL for Lambda container images"
  value       = local.public_registry_url
}

output "public_ecr_repository_metadata" {
  description = "Public ECR repository metadata"
  value = {
    name           = local.repository_name
    repository_url = local.repository_url
    registry_id    = local.registry_id
    region         = local.registry_region
  }
}

output "usage_instructions" {
  description = "Instructions for using the public ECR repository"
  value = {
    docker_pull_command = "docker pull ${local.public_registry_url}:latest"
    lambda_image_uri = "${local.repository_url}:latest"
    public_read_access = "This repository is publicly accessible and can be used by Lambda functions without additional permissions"
    authentication_required = false
  }
}

# Resource tags for tracking
data "aws_caller_identity" "current" {}

locals {
  resource_tags = merge(var.common_tags, {
    RepositoryType = "Public ECR Reference"
    Environment   = var.environment
    ServiceName   = var.service_name
    Project       = "Client Code Management"
    Owner         = "DevOps Team"
  })
}

resource "null_resource" "repository_info" {
  provisioner "local-exec" {
    command = "echo 'Public ECR Repository Reference Configured: public.ecr.aws/x7o9n0b1/clients-code'"
  }
  
  triggers = {
    repository_url = local.repository_url
    timestamp     = timestamp()
  }
}
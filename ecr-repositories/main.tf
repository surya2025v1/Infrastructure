# Public ECR Repository Configuration for Client Applications
# References existing public ECR repository: public.ecr.aws/x7o9n0b1/clients-code
# Configures Lambda access permissions

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

# Data source for existing public ECR repository
data "aws_ecr_repository" "public_clients_code" {
  name = "clients-code"
}

# Output the public ECR repository information for Lambda usage
locals {
  public_registry_url = "public.ecr.aws/x7o9n0b1/clients-code"
}

output "public_ecr_repository_url" {
  description = "Public ECR repository URL for Lambda container images"
  value       = local.public_registry_url
}

output "public_ecr_repository_metadata" {
  description = "Public ECR repository metadata"
  value = {
    name         = data.aws_ecr_repository.public_clients_code.name
    repository_uri = data.aws_ecr_repository.public_clients_code.repository_url
    registry_id  = data.aws_ecr_repository.public_clients_code.registry_id
    arn          = data.aws_ecr_repository.public_clients_code.arn
  }
}

# Documentation for using this repository with Lambda
output "usage_instructions" {
  description = "Instructions for using the public ECR repository"
  value = {
    docker_pull_command = "docker pull ${local.public_registry_url}:latest"
    lambda_image_uri = "${data.aws_ecr_repository.public_clients_code.repository_url}:latest"
    public_read_access = "This repository is publicly accessible and can be used by Lambda functions without additional permissions"
    authentication_required = false
  }
}

# Tags for tracking
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

resource "null_resource" "logging" {
  provisioner "local-exec" {
    command = "echo 'Public ECR Repository Reference Configured: public.ecr.aws/x7o9n0b1/clients-code'"
  }
  
  triggers = {
    timestamp = timestamp()
  }
}

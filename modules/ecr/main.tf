# ECR Repository Module
# Creates ECR repositories based on provided registry and repository name

# Extract registry information for private ECR
locals {
  registry_id = var.ecr_registry
  repo_name   = var.ecr_repository != "" ? var.ecr_repository : "lambda-${random_string.repo_suffix.result}"
  
  # Extract AWS account and region from registry URL
  aws_account = replace(var.ecr_registry, "/([0-9]+)\\.dkr\\.ecr\\.(.+)\\.amazonaws\\.com/", "$1")
  aws_region  = replace(var.ecr_registry, "/([0-9]+)\\.dkr\\.ecr\\.(.+)\\.amazonaws\\.com/", "$2")
}

# Generate random suffix for repository name if not provided
resource "random_string" "repo_suffix" {
  count   = var.ecr_repository == "" ? 1 : 0
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# Private ECR Repository
resource "aws_ecr_repository" "private_repo" {
  name                 = local.repo_name
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key_id      = var.kms_key_id
  }
  
  force_delete = var.force_delete
  
  tags = merge(var.tags, {
    Name        = local.repo_name
    Type        = "Private ECR Repository"
    Repository  = "ECR"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project_name
  })
}

# Generate automatic lifecycle policy based on max_images configuration
locals {
  # Create automatic lifecycle policy if enabled and no custom policy provided
  auto_lifecycle_policy = var.enable_automatic_lifecycle_policy ? jsonencode({
    rules = [
      # Rule 1: Keep only max_images tagged images (simple Docker image retention)
      {
        rulePriority = 1
        description  = "Keep last ${var.max_images} tagged Docker images"
        selection = {
          tagStatus   = "tagged"
          countCategory = "imageCountMoreThan"
          countNumber   = var.max_images
        }
        action = {
          type = "expire"
        }
      },
      # Rule 2: Delete untagged images after specified days (cleanup intermediate layers)
      {
        rulePriority = 2
        description  = "Delete untagged images after ${var.untagged_image_retention_days} days"
        selection = {
          tagStatus     = "untagged"
          countCategory = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = var.untagged_image_retention_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  }) : null
  
  # Final lifecycle policy - use custom policy if provided, otherwise use auto-generated
  final_lifecycle_policy = var.lifecycle_policy != null ? 
    var.lifecycle_policy : local.auto_lifecycle_policy
}

# Lifecycle policy for ECR repository
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  count = local.final_lifecycle_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.private_repo.name
  
  policy = local.final_lifecycle_policy
}

# Repository policy for ECR repository
resource "aws_ecr_repository_policy" "repo_policy" {
  count = var.repository_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.private_repo.name
  
   policy = var.repository_policy
}

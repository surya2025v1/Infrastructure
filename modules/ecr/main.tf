# ECR Repository Module
# Creates ECR repositories based on provided registry and repository name

# Data source to detect if we're using AWS Public ECR
data "external" "ecr_registry_info" {
  program = ["bash", "${path.module}/detect_ecr_type.sh", var.ecr_registry]
}

locals {
  is_public_ecr = data.external.ecr_registry_info.result["is_public_ecr"]
  registry_id   = data.external.ecr_registry_info.result["registry_id"]
  repo_name     = data.external.ecr_registry_info.result["repo_name"]
  aws_account   = data.external.ecr_registry_info.result["aws_account"]
  aws_region    = data.external.ecr_registry_info.result["aws_region"]
}

# Private ECR Repository (for private ECR)
resource "aws_ecr_repository" "private_repo" {
  count = local.is_public_ecr == "false" ? 1 : 0
  
  name                 = local.repo_name
  image_tag_mutability = var.image_tag_mutability
  
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
  
  encryption_configuration {
    encryption_type = var.encryption_type
  }
  
  force_delete = var.force_delete
  
  tags = merge(var.tags, {
    Name        = local.repo_name
    Type        = "Private ECR Repository"
    Repository  = "ECR"
    ManagedBy   = "Terraform"
  })
}

# Public ECR Repository (for AWS Public ECR)
resource "aws_ecrpublic_repository" "public_repo" {
  count = local.is_public_ecr == "true" ? 1 : 0
  
  repository_name = local.repo_name
  
  catalog_data {
    description     = var.description != "" ? var.description : "Public ECR repository for ${local.repo_name}"
    architectures   = var.architectures
    operating_systems = var.operating_systems
    
    about_text      = var.about_text
    usage_text      = var.usage_text
    logo_image_blob = var.logo_image_blob
  }
  
  tags = merge(var.tags, {
    Name        = local.repo_name
    Type        = "Public ECR Repository"
    Repository  = "ECR-Public"
    ManagedBy   = "Terraform"
  })
}

# Generate automatic lifecycle policy based on max_images configuration
locals {
  # Create automatic lifecycle policy if enabled and no custom policy provided
  auto_lifecycle_policy = var.enable_automatic_lifecycle_policy ? jsonencode({
    rules = concat(
      # Rule 1: Keep only max_images for tagged images with priority prefix
      [
        {
          rulePriority = 1
          description  = "Keep last ${var.max_images} images with '${var.lifecycle_policy_priority_tag_prefix}' prefix"
          selection = {
            tagStatus     = "tagged"
            tagPrefixList = [var.lifecycle_policy_priority_tag_prefix]
            countType     = "imageCountMoreThan"
            countNumber   = var.max_images
          }
          action = {
            type = "expire"
          }
        }
      ],
      # Rule 2: Keep only max_images for all other tagged images
      [
        {
          rulePriority = 2
          description  = "Keep last ${var.max_images} tagged images (excluding '${var.lifecycle_policy_priority_tag_prefix}' prefix)"
          selection = {
            tagStatus     = "tagged"
            countType     = "imageCountMoreThan"
            countNumber   = var.max_images
          }
          action = {
            type = "expire"
          }
        }
      ],
      # Rule 3: Delete untagged images after specified days
      var.untagged_image_retention_days > 0 ? [
        {
          rulePriority = 3
          description  = "Delete untagged images after ${var.untagged_image_retention_days} days"
          selection = {
            tagStatus     = "untagged"
            countType     = "sinceImagePushed"
            countUnit     = "days"
            countNumber   = var.untagged_image_retention_days
          }
          action = {
            type = "expire"
          }
        }
      ] : []
    )
  }) : null
  
  # Final lifecycle policy - use custom policy if provided, otherwise use auto-generated
  final_lifecycle_policy = local.is_public_ecr == "false" && var.lifecycle_policy != null ? 
    var.lifecycle_policy : local.auto_lifecycle_policy
}

# Lifecycle policy for private ECR repository
resource "aws_ecr_lifecycle_policy" "private_repo_policy" {
  count = local.is_public_ecr == "false" && local.final_lifecycle_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.private_repo[0].name
  
  policy = local.final_lifecycle_policy
}

# Repository policy for private ECR repository
resource "aws_ecr_repository_policy" "private_repo_policy" {
  count = local.is_public_ecr == "false" && var.repository_policy != null ? 1 : 0
  
  repository = aws_ecr_repository.private_repo[0].name
  
  policy = var.repository_policy
}

# Public repository policy for AWS Public ECR
resource "aws_ecrpublic_repository_policy" "public_repo_policy" {
  count = local.is_public_ecr == "true" && var.repository_policy != null ? 1 : 0
  
  repository_name = aws_ecrpublic_repository.public_repo[0].repository_name
  
  policy = var.repository_policy
}

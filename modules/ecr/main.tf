# Simple ECR Repository Module
# Creates ECR repository with automatic lifecycle policy (10 images max)

# ECR Repository
resource "aws_ecr_repository" "repo" {
  name = var.repository_name
  
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  encryption_configuration {
    encryption_type = "AES256"
  }
  
  force_delete = false
  
  tags = merge(var.tags, {
    Name        = var.repository_name
    Type        = "ECR Repository"
    ManagedBy   = "Terraform"
  })
}

# Automatic lifecycle policy - keep 10 images max
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.repo.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 tagged images"
        selection = {
          tagStatus   = "tagged"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images after 1 day"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
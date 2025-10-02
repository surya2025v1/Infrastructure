
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
    key            = "global/ecr/common/terraform.tfstate"
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
      ManagedBy    = "Terraform"
      FunctionName = "common"
      client       = "common"
    }
  }
}



# Private ECR Repository for Lambda Functions
module "private_user_api" {
  source = "../modules/ecr"
  
  # Use your AWS account ID
  ecr_registry = "103056765659.dkr.ecr.us-east-1.amazonaws.com"
  ecr_repository = "user-api-v2"
  
  description = "Private repository for Temple User API Lambda function"
  image_tag_mutability = "MUTABLE"
  scan_on_push = var.scan_on_push
  encryption_type = "AES256"
  
  # Repository policy allowing GitHub Actions and Lambda access
  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "GitHubActionsAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::103056765659:user/gitlab_ui_deployment"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      },
      {
        Sid    = "LambdaExecutionRoleAccess"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
      }
    ]
  })
  
  # Automatic Image Retention Configuration
  max_images = var.max_images
  untagged_image_retention_days = var.untagged_image_retention_days
  lifecycle_policy_priority_tag_prefix = var.lifecycle_policy_priority_tag_prefix
  
  tags = merge(var.common_tags, {
    Service = "User API"
    Type    = "Lambda Function"
  })
}

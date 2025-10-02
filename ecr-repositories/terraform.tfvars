aws_region = "us-east-2"
repository_name = "user-api-v1"
service_name = "Temple User API"
service_description = "Private repository for Temple User API Lambda functions"
environment = "prod"

# ECR Registry Configuration
ecr_registry = "103056765659.dkr.ecr.us-east-1.amazonaws.com"

# Image Scanning and Settings
scan_on_push = true
image_tag_mutability = "MUTABLE"
encryption_type = "AES256"

# Image Retention Settings
max_images = 10
untagged_image_retention_days = 1
enable_automatic_lifecycle_policy = true

# Repository Policy (allowing GitHub Actions and Lambda access)
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

# Additional tags
tags = {
  Project     = "Temple Management"
  Environment = "prod"
  Owner       = "DevOps Team"
  Purpose     = "Lambda Function Deployment"
  Repository  = "ECR"
}

client = "TempleManagement"
controlled_by = "Terraform"

# Pipeline control flags
create = true
delete = false
# Terraform Variables Configuration
# Private ECR Repository Configuration for Temple Management System

repository_name = "user-api-v2"
service_name    = "Temple User API"
environment     = "prod"

common_tags = {
  Project     = "Temple Management"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Environment = "prod"
  Purpose     = "Lambda Function Deployment"
}

scan_on_push = true
image_tag_mutability = "MUTABLE"
encryption_type = "AES256"

max_images = 10
untagged_image_retention_days = 1
lifecycle_policy_priority_tag_prefix = "v"
# Outputs for ECR Repository Module

output "registry_id" {
  description = "Registry ID"
  value       = local.registry_id
}

output "repository_name" {
  description = "Repository name"
  value       = local.repo_name
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = local.aws_account
}

output "aws_region" {
  description = "AWS region"
  value       = local.aws_region
}

# ECR Repository Outputs
output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.private_repo.arn
}

output "repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.private_repo.repository_url
}

# Docker login command
output "docker_login_command" {
  description = "Docker login command for the registry"
  value       = "aws ecr get-login-password --region ${local.aws_region} | docker login --username AWS --password-stdin ${local.registry_id}"
}

# Tags for reference
output "tags" {
  description = "Tags applied to the ECR repository"
  value       = aws_ecr_repository.private_repo.tags_all
}

# Lifecycle policy information
output "lifecycle_policy_applied" {
  description = "Whether a lifecycle policy was applied"
  value       = local.final_lifecycle_policy != null
}

output "max_images_configured" {
  description = "Maximum number of images configured for retention"
  value       = var.max_images
}

output "untagged_retention_days" {
  description = "Number of days for untagged image retention"
  value       = var.untagged_image_retention_days
}

output "lifecycle_policy_json" {
  description = "JSON of the applied lifecycle policy"
  value       = local.final_lifecycle_policy
}

# Image cleanup summary
output "image_retention_summary" {
  description = "Summary of image retention configuration"
  value = {
    max_images                    = var.max_images
    untagged_retention_days       = var.untagged_image_retention_days
    priority_tag_prefix          = var.lifecycle_policy_priority_tag_prefix
    automatic_policy_enabled     = var.enable_automatic_lifecycle_policy
    custom_policy_used          = var.lifecycle_policy != null
    cleanup_rules_count         = var.enable_automatic_lifecycle_policy ? 3 : 0
  }
}

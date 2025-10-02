# Outputs for ECR Repository Module

output "ecr_registry_type" {
  description = "Type of ECR registry (private or public)"
  value       = data.external.ecr_registry_info.result["is_public_ecr"] == "true" ? "public" : "private"
}

output "registry_id" {
  description = "Registry ID extracted from ECR registry URL"
  value       = data.external.ecr_registry_info.result["registry_id"]
}

output "repository_name" {
  description = "Repository name extracted from ECR registry URL"
  value       = local.repo_name
}

output "aws_account_id" {
  description = "AWS account ID extracted from registry URL"
  value       = data.external.ecr_registry_info.result["aws_account"]
}

output "aws_region" {
  description = "AWS region extracted from registry URL"
  value       = data.external.ecr_registry_info.result["aws_region"]
}

# Private ECR Repository Outputs
output "private_repository_name" {
  description = "Name of the private ECR repository"
  value       = local.is_public_ecr == "false" ? aws_ecr_repository.private_repo[0].name : null
}

output "private_repository_arn" {
  description = "ARN of the private ECR repository"
  value       = local.is_public_ecr == "false" ? aws_ecr_repository.private_repo[0].arn : null
}

output "private_repository_url" {
  description = "URL of the private ECR repository"
  value       = local.is_public_ecr == "false" ? aws_ecr_repository.private_repo[0].repository_url : null
}

output "private_registry_id" {
  description = "Registry ID of the private ECR repository"
  value       = local.is_public_ecr == "false" ? aws_ecr_repository.private_repo[0].registry_id : null
}

# Public ECR Repository Outputs
output "public_repository_name" {
  description = "Name of the public ECR repository"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].repository_name : null
}

output "public_repository_arn" {
  description = "ARN of the public ECR repository"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].arn : null
}

output "public_repository_uri" {
  description = "URI of the public ECR repository"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].repository_uri : null
}

output "public_registry_id" {
  description = "Registry ID of the public ECR repository"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].registry_id : null
}

# Combined outputs for easy use
output "repository_arn" {
  description = "ARN of the created ECR repository (private or public)"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].arn : aws_ecr_repository.private_repo[0].arn
}

output "repository_url" {
  description = "URL/URI of the created ECR repository (private or public)"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].repository_uri : aws_ecr_repository.private_repo[0].repository_url
}

output "repository_name" {
  description = "Name of the created ECR repository (private or public)"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].repository_name : aws_ecr_repository.private_repo[0].name
}

# Docker login commands
output "docker_login_command" {
  description = "Docker login command for the registry"
  value = local.is_public_ecr == "true" ? 
    "aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${local.registry_id}" :
    "aws ecr get-login-password --region ${local.aws_region} | docker login --username AWS --password-stdin ${local.registry_id}"
}

# Tags for reference
output "tags" {
  description = "Tags applied to the ECR repository"
  value       = local.is_public_ecr == "true" ? aws_ecrpublic_repository.public_repo[0].tags_all : aws_ecr_repository.private_repo[0].tags_all
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
  value       = local.is_public_ecr == "true" ? null : local.final_lifecycle_policy
}

# Image cleanup summary
output "image_retention_summary" {
  description = "Summary of image retention configuration"
  value = local.is_public_ecr == "false" ? {
    max_images                    = var.max_images
    untagged_retention_days       = var.untagged_image_retention_days
    priority_tag_prefix          = var.lifecycle_policy_priority_tag_prefix
    automatic_policy_enabled     = var.enable_automatic_lifecycle_policy
    custom_policy_used          = var.lifecycle_policy != null
    cleanup_rules_count         = var.enable_automatic_lifecycle_policy ? 3 : 0
  } : null
}

# Simple ECR Repository Outputs

output "repository_url" {
  description = "URL of the created ECR repository"
  value       = module.ecr_repository.repository_url
}

output "repository_name" {
  description = "Name of the created ECR repository"
  value       = module.ecr_repository.repository_name
}
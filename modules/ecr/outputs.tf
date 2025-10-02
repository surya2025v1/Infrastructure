# Simple ECR Repository Module Outputs

output "repository_url" {
  description = "URL of the created ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}

output "repository_name" {
  description = "Name of the created ECR repository"
  value       = aws_ecr_repository.repo.name
}

output "registry_id" {
  description = "Registry ID of the ECR repository"
  value       = aws_ecr_repository.repo.registry_id
}

output "arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.repo.arn
}
# Simple ECR Repository Outputs

output "repository_url" {
  description = "URL of the created ECR repository"
  value       = module.ecr_repository.repository_url
}

output "repository_name" {
  description = "Name of the created ECR repository"
  value       = module.ecr_repository.repository_name
}

# Pipeline expected outputs
output "all_repositories" {
  description = "All repository information for pipeline"
  value = {
    repositories = [{
      name = module.ecr_repository.repository_name
      type = "Private ECR"
      url  = module.ecr_repository.repository_url
    }]
  }
}

output "image_retention_summary" {
  description = "Image retention configuration summary"
  value = {
    "${module.ecr_repository.repository_name}" = {
      max_images = 10
      untagged_retention_days = 1
    }
  }
}

output "github_actions_secrets" {
  description = "Secrets needed for GitHub Actions"
  value = {
    ECR_REGISTRY = replace(module.ecr_repository.repository_url, "/\\/[^/]+$/", "")
    ECR_REPOSITORY = module.ecr_repository.repository_name
    AWS_REGION = var.aws_region
  }
}

output "docker_commands" {
  description = "Docker commands for working with the repository"
  value = {
    login_private = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${replace(module.ecr_repository.repository_url, "/\\/[^/]+$/", "")}"
    push_command = "docker push ${module.ecr_repository.repository_url}:latest"
  }
}
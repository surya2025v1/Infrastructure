# Outputs for ECR Repository Examples

output "public_repository_info" {
  description = "Information about the public ECR repository"
  value = {
    url    = module.public_clients_code.repository_url
    name   = module.public_clients_code.repository_name
    arn    = module.public_clients_code.repository_arn
    type   = module.public_clients_code.ecr_registry_type
    login_command = module.public_clients_code.docker_login_command
  }
}

output "private_repository_info" {
  description = "Information about the private ECR repository"
  value = {
    url    = module.private_user_api.repository_url
    name   = module.private_user_api.repository_name
    arn    = module.private_user_api.repository_arn
    type   = module.private_user_api.ecr_registry_type
    login_command = module.private_user_api.docker_login_command
  }
}

output "dynamic_repository_info" {
  description = "Information about the dynamically created ECR repository"
  value = {
    url    = module.dynamic_ecr_repo.repository_url
    name   = module.dynamic_ecr_repo.repository_name
    arn    = module.dynamic_ecr_repo.repository_arn
    type   = module.dynamic_ecr_repo.ecr_registry_type
    login_command = module.dynamic_ecr_repo.docker_login_command
  }
}

output "all_repositories" {
  description = "Summary of all created repositories"
  value = {
    repositories = [
      {
        name      = module.public_clients_code.repository_name
        url       = module.public_clients_code.repository_url
        type      = "public"
        service   = "Client Tools"
        max_images = "N/A"
      },
      {
        name      = module.private_user_api.repository_name
        url       = module.private_user_api.repository_url
        type      = "private"
        service   = "User API"
        max_images = module.private_user_api.max_images_configured
      },
      {
        name      = module.dynamic_ecr_repo.repository_name
        url       = module.dynamic_ecr_repo.repository_url
        type      = module.dynamic_ecr_repo.ecr_registry_type
        service   = var.service_name
        max_images = module.dynamic_ecr_repo.max_images_configured
      },
      {
        name      = module.high_volume_ecr.repository_name
        url       = module.high_volume_ecr.repository_url
        type      = "private"
        service   = "CI Builds"
        max_images = module.high_volume_ecr.max_images_configured
      },
      {
        name      = module.long_term_ecr.repository_name
        url       = module.long_term_ecr.repository_url
        type      = "private"
        service   = "Production Releases"
        max_images = module.long_term_ecr.max_images_configured
      }
    ]
  }
}

# Image retention summary for all repositories
output "image_retention_summary" {
  description = "Summary of image retention configuration for all private repositories"
  value = {
    user_api = module.private_user_api.image_retention_summary
    dynamic_repo = module.dynamic_ecr_repo.image_retention_summary
    ci_builds = module.high_volume_ecr.image_retention_summary
    production = module.long_term_ecr.image_retention_summary
  }
}

# Outputs useful for GitHub Actions workflows
output "github_actions_secrets" {
  description = "Secrets needed for GitHub Actions ECR configuration"
  value = {
    ECR_REGISTRY     = module.private_user_api.registry_id
    ECR_REPOSITORY   = module.private_user_api.repository_name
    AWS_REGION       = module.private_user_api.aws_region
    ECR_LOGIN_CMD    = "echo '${module.private_user_api.docker_login_command}'"
  }
}

output "docker_commands" {
  description = "Useful Docker commands for the repositories"
  value = {
    login_public     = module.public_clients_code.docker_login_command
    login_private    = module.private_user_api.docker_login_command
    
    build_commands = {
      public_image   = "docker build -t ${module.public_clients_code.repository_url}:latest ."
      private_image  = "docker build -t ${module.private_user_api.repository_url}:latest ."
    }
    
    push_commands = {
      public_push    = "docker push ${module.public_clients_code.repository_url}:latest"
      private_push   = "docker push ${module.private_user_api.repository_url}:latest"
    }
  }
}

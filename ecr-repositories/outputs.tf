# Outputs for Public ECR Repository Reference

output "public_repository_url" {
  description = "Public ECR repository URL for Lambda container usage"
  value       = "public.ecr.aws/x7o9n0b1/clients-code"
}

output "registry_url" {
  description = "Full registry URL with namespace"
  value       = "public.ecr.aws/x7o9n0b1/clients-code"
}

output "lambda_image_uri_example" {
  description = "Example image URI for Lambda function container configuration"
  value       = "public.ecr.aws/x7o9n0b1/clients-code:latest"
}

output "docker_commands" {
  description = "Useful Docker commands for working with this public repository"
  value = {
    pull_command = "docker pull public.ecr.aws/x7o9n0b1/clients-code:latest"
    tag_command  = "docker tag your-image:latest public.ecr.aws/x7o9n0b1/clients-code:v1.0.0"
    push_command = "aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws"
    push_after_login = "docker push public.ecr.aws/x7o9n0b1/clients-code:v1.0.0"
  }
}

output "lambda_usage_instructions" {
  description = "Instructions for using this repository with AWS Lambda"
  value = {
    container_image_uri = "public.ecr.aws/x7o9n0b1/clients-code:latest"
    required_permissions = "No additional permissions required (public repository)"
    note = "Lambda execution role needs no ECR permissions for public repositories"
    examples = {
      terraform_lambda_code = jsonencode({
        image_uri = "public.ecr.aws/x7o9n0b1/clients-code:latest"
        package_type = "Image"
      })
    }
  }
}

output "repository_info" {
  description = "Complete repository information"
  value = {
    name           = "clients-code"
    repository_url = "public.ecr.aws/x7o9n0b1/clients-code"
    registry_id    = "x7o9n0b1"
    region         = "us-east-1"
    note           = "Public ECR repository - no Terraform state tracking needed"
  }
}
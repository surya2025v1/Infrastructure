# Public ECR Repository Configuration
# References existing public ECR repository: public.ecr.aws/x7o9n0b1/clients-code

# =============================================================================
# PUBLIC ECR REPOSITORY CONFIGURATION
# =============================================================================

# Environment Configuration
environment     = "prod"
service_name    = "Clients Code Repository"
project_description = "Reference to public ECR repository for storing client application Docker images"

# Common Tags
common_tags = {
  Project     = "Client Application Management"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Environment = "prod"
  Purpose     = "Public ECR Repository Reference"
  Repository  = "public.ecr.aws/x7o9n0b1/clients-code"
}

# Lambda Functions that will use this repository
lambda_function_names = [
  "clients-api-lambda",
  "temple-user-api-v2"
]

# =============================================================================
# PUBLIC ECR USAGE INSTRUCTIONS
# =============================================================================
#
# This configuration references the existing public ECR repository:
# Repository: public.ecr.aws/x7o9n0b1/clients-code
# 
# Lambda functions can use this repository WITHOUT additional IAM permissions
# since it's a public repository.
# 
# To use in Lambda:
# 1. Build your Docker image: docker build -t my-client-app .
# 2. Tag for public ECR: docker tag my-client-app public.ecr.aws/x7o9n0b1/clients-code:v1.0.0
# 3. Push to public ECR: docker push public.ecr.aws/x7o9n0b1/clients-code:v1.0.0
# 4. Use in Lambda: public.ecr.aws/x7o9n0b1/clients-code:v1.0.0
#
# Benefits of Public ECR:
# - No authentication required for Lambda to access
# - No IAM permissions needed for Lambda execution role
# - Easy sharing across AWS accounts
# - Reduced cost (no storage costs for public images)
#
# Notes:
# - Make sure Docker images are tagged before pushing
# - Use semantic versioning (e.g., v1.0.0, v1.1.0)
# - Images are publicly accessible, ensure no sensitive data

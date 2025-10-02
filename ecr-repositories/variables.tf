# Variables for Public ECR Repository Reference

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "service_name" {
  description = "Service name for description and tagging"
  type        = string
  default     = "Clients Code Repository"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "Client Application Management"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}

# Optional configuration for tracking purposes
variable "project_description" {
  description = "Description of the project using this public ECR"
  type        = string
  default     = "Reference to public ECR repository for client applications"
}

variable "lambda_function_names" {
  description = "List of Lambda function names that will use this public ECR repository"
  type        = list(string)
  default     = []
}

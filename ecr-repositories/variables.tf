# Variables for ECR Repository Examples

variable "ecr_registry_url" {
  description = "Full ECR registry URL (e.g., 'public.ecr.aws/x7o9n0b1' or '123456789012.dkr.ecr.us-east-1.amazonaws.com')"
  type        = string
}

variable "repository_name" {
  description = "Repository name (e.g., 'clients-code', 'user-api-v2')"
  type        = string
}

variable "service_name" {
  description = "Service name for description and tagging"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default    = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Project     = "Temple Management"
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
}

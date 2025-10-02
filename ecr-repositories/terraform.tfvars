# Variables for Private ECR Repository

variable "repository_name" {
  description = "ECR repository name for Lambda function"
  type        = string
}

variable "service_name" {
  description = "Service name for description and tagging"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
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

variable "encryption_type" {
  description = "Encryption type for repository"
  type        = string
  default     = "AES256"
}

variable "max_images" {
  description = "Maximum number of images to retain"
  type        = number
  default     = 10
}

variable "untagged_image_retention_days" {
  description = "Days to retain untagged images"
  type        = number
  default     = 1
}

variable "lifecycle_policy_priority_tag_prefix" {
  description = "Priority tag prefix for lifecycle policy"
  type        = string
  default     = "v"
}
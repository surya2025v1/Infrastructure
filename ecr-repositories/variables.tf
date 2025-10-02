# Variables for ECR repository

variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "repository_name" {
  description = "ECR repository name for Lambda function"
  type        = string
}

variable "service_name" {
  description = "Service name for description and tagging"
  type        = string
}

variable "service_description" {
  description = "Description of the ECR repository"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "client" {
  description = "Client name for the project"
  type        = string
  default     = "TBD"
}

variable "ecr_registry" {
  description = "Private ECR registry URL (e.g., '103056765659.dkr.ecr.us-east-1.amazonaws.com')"
  type        = string
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
  description = "Maximum number of tagged Docker images to retain in the repository (for Lambda deployments). When exceeded, oldest images will be deleted automatically."
  type        = number
  default     = 10
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged Docker images (intermediate build layers) before deletion. Set to 0 to delete immediately."
  type        = number
  default     = 1
}

variable "enable_automatic_lifecycle_policy" {
  description = "Enable automatic lifecycle policy creation to manage Docker image retention"
  type        = bool
  default     = true
}

variable "repository_policy" {
  description = "Repository policy JSON (works for both private and public ECR)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to the ECR repository"
  type        = map(string)
  default     = {}
}

variable "controlled_by" {
  description = "Tag indicating what controls this resource"
  type        = string
  default     = "Terraform"
}
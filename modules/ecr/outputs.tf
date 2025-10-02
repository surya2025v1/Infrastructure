# Variables for ECR Repository Module

variable "ecr_registry" {
  description = "Private ECR registry URL (e.g., '123456789012.dkr.ecr.us-east-1.amazonaws.com')"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repository name for Lambda function"
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for private ECR"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be either MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push for private ECR"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for private ECR repository"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be either AES256 or KMS."
  }
}

variable "force_delete" {
  description = "Whether to force delete repository if images exist"
  type        = bool
  default     = false
}

variable "description" {
  description = "Description for the ECR repository"
  type        = string
  default     = ""
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON for private ECR repository"
  type        = string
  default     = null
}

variable "max_images" {
  description = "Maximum number of tagged Docker images to retain in the repository (for Lambda deployments). When exceeded, oldest images will be deleted automatically."
  type        = number
  default     = 10
  validation {
    condition     = var.max_images > 0 && var.max_images <= 100
    error_message = "Maximum images must be between 1 and 100."
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged Docker images (intermediate build layers) before deletion. Set to 0 to delete immediately."
  type        = number
  default     = 1
  validation {
    condition     = var.untagged_image_retention_days >= 0 && var.untagged_image_retention_days <= 365
    error_message = "Untagged image retention days must be between 0 and 365."
  }
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

# Optional: KMS key for encryption (for private ECR with KMS encryption)
variable "kms_key_id" {
  description = "KMS key ID for encryption (for private ECR with KMS encryption type)"
  type        = string
  default     = null
}

# Optional: Environment-specific configurations
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = ""
}

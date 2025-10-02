# Variables for ECR Repository Module

variable "ecr_registry" {
  description = "Full ECR registry URL (e.g., 'public.ecr.aws/x7o9n0b1', '123456789012.dkr.ecr.us-east-1.amazonaws.com')"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repository name (will be extracted from ecr_registry if not provided)"
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

variable "architectures" {
  description = "Supported architectures for public ECR repository"
  type        = list(string)
  default     = ["x86-64", "arm64"]
}

variable "operating_systems" {
  description = "Supported operating systems for public ECR repository"
  type        = list(string)
  default     = ["Linux"]
}

variable "about_text" {
  description = "About text for public ECR repository catalog"
  type        = string
  default     = ""
}

variable "usage_text" {
  description = "Usage text for public ECR repository catalog"
  type        = string
  default     = ""
}

variable "logo_image_blob" {
  description = "Logo image blob for public ECR repository catalog (base64 encoded)"
  type        = string
  default     = ""
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON for private ECR repository"
  type        = string
  default     = null
}

variable "max_images" {
  description = "Maximum number of images to retain in the repository. When exceeded, oldest images will be deleted."
  type        = number
  default     = 10
  validation {
    condition     = var.max_images > 0 && var.max_images <= 100
    error_message = "Maximum images must be between 1 and 100."
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images before deletion"
  type        = number
  default     = 1
  validation {
    condition     = var.untagged_image_retention_days >= 0 && var.untagged_image_retention_days <= 365
    error_message = "Untagged image retention days must be between 0 and 365."
  }
}

variable "enable_automatic_lifecycle_policy" {
  description = "Enable automatic lifecycle policy creation based on max_images and untagged_image_retention_days"
  type        = bool
  default     = true
}

variable "lifecycle_policy_priority_tag_prefix" {
  description = "Tage prefix to prioritize for image retention (e.g., 'v', 'release', 'prod')"
  type        = string
  default     = "v"
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

# Variables for S3 Module (Python API Storage)

variable "bucket_name" {
  description = "Name of the S3 bucket for storing Python API files"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "controlled_by" {
  description = "Tag indicating what controls this resource"
  type        = string
  default     = "Terraform"
}

variable "client" {
  description = "Client name for the project"
  type        = string
  default     = "TBD"
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "create" {
  description = "Flag to control S3 bucket creation"
  type        = bool
  default     = true
}

variable "delete" {
  description = "Flag to control S3 bucket deletion"
  type        = bool
  default     = false
} 
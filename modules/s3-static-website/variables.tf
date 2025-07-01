# Variables for S3 Static Website Module

variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting"
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
  default     = false
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for the website"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_100, PriceClass_200, PriceClass_All."
  }
}

variable "cloudfront_aliases" {
  description = "List of domain names for CloudFront distribution"
  type        = list(string)
  default     = []
} 
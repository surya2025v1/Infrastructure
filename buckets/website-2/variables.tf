# Variables for website-2 bucket

variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting"
  type        = string
  default     = "website-2-static-site"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}



variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for the website"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class (PriceClass_100, PriceClass_200, PriceClass_All)"
  type        = string
  default     = "PriceClass_200"
}

variable "cloudfront_aliases" {
  description = "List of domain names for CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for the resources"
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
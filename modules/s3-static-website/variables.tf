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
  default     = true
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

variable "cloudfront_min_ttl" {
  description = "The minimum amount of time that CloudFront caches HTTP status codes that you specify"
  type        = number
  default     = 0
}

variable "cloudfront_default_ttl" {
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache"
  type        = number
  default     = 3600
}

variable "cloudfront_max_ttl" {
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache"
  type        = number
  default     = 86400
}

variable "cloudfront_geo_restriction_type" {
  description = "The method that you want to use to restrict distribution of your content by country (none, whitelist, blacklist)"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.cloudfront_geo_restriction_type)
    error_message = "CloudFront geo restriction type must be one of: none, whitelist, blacklist."
  }
}

variable "cloudfront_geo_restriction_locations" {
  description = "The ISO 3166-1-alpha-2 codes for countries you want CloudFront to distribute your content from"
  type        = list(string)
  default     = []
}

variable "cloudfront_certificate_type" {
  description = "Type of SSL certificate to use (cloudfront, acm)"
  type        = string
  default     = "cloudfront"
  validation {
    condition     = contains(["cloudfront", "acm"], var.cloudfront_certificate_type)
    error_message = "CloudFront certificate type must be one of: cloudfront, acm."
  }
}

variable "cloudfront_acm_certificate_arn" {
  description = "The ARN of the AWS Certificate Manager certificate that you wish to use with this distribution"
  type        = string
  default     = null
}

variable "cloudfront_minimum_protocol_version" {
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections"
  type        = string
  default     = "TLSv1.2"
  validation {
    condition     = contains(["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2", "TLSv1.3"], var.cloudfront_minimum_protocol_version)
    error_message = "CloudFront minimum protocol version must be one of: SSLv3, TLSv1, TLSv1.1, TLSv1.2, TLSv1.3."
  }
}

variable "cloudfront_web_acl_id" {
  description = "A unique identifier that specifies the AWS WAF web ACL, if any, to associate with this distribution"
  type        = string
  default     = null
} 
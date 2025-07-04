variable "create" {
  description = "Whether to create the API Gateway resources"
  type        = bool
  default     = true
}

variable "ignore_existing_stage" {
  description = "When true, creates a new stage even if one exists (may cause conflicts). When false, skips stage creation if stage already exists."
  type        = bool
  default     = false
}

variable "api_name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = "API Gateway for multiple Lambda functions"
}

variable "endpoint_type" {
  description = "Type of API Gateway endpoint"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "Endpoint type must be one of: REGIONAL, EDGE, PRIVATE."
  }
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "prod"
}

variable "authorization_type" {
  description = "Type of authorization for API Gateway methods"
  type        = string
  default     = "NONE"
  validation {
    condition     = contains(["NONE", "AWS_IAM", "CUSTOM", "COGNITO_USER_POOLS"], var.authorization_type)
    error_message = "Authorization type must be one of: NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS."
  }
}

variable "authorizer_id" {
  description = "ID of the API Gateway authorizer (if using CUSTOM authorization)"
  type        = string
  default     = null
}

variable "enable_logging" {
  description = "Whether to enable CloudWatch logging for API Gateway"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "controlled_by" {
  description = "Entity controlling this resource"
  type        = string
  default     = "terraform"
}

variable "client" {
  description = "Client or project name"
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Security Configuration Variables
variable "enable_waf" {
  description = "Whether to enable WAF protection for API Gateway"
  type        = bool
  default     = false
}

variable "enable_usage_plans" {
  description = "Whether to enable API Gateway usage plans and API keys"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Whether to enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = null
}

# CORS Configuration
variable "cors_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_credentials" {
  description = "Whether to allow credentials in CORS requests"
  type        = bool
  default     = true
}

variable "cors_allow_methods" {
  description = "List of allowed HTTP methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"]
}

variable "cors_allow_headers" {
  description = "List of allowed headers for CORS"
  type        = list(string)
  default     = ["Content-Type", "Authorization", "X-Requested-With", "X-API-Key", "X-Amz-Date", "X-Amz-Security-Token"]
}

variable "cors_expose_headers" {
  description = "List of headers to expose in CORS responses"
  type        = list(string)
  default     = ["X-RateLimit-Limit", "X-RateLimit-Remaining", "X-RateLimit-Reset", "X-Process-Time"]
}

variable "cors_max_age" {
  description = "Maximum age for CORS preflight requests in seconds"
  type        = number
  default     = 86400
}

# Rate Limiting Configuration
variable "rate_limit" {
  description = "Rate limit (requests per second)"
  type        = number
  default     = 100
}

variable "burst_limit" {
  description = "Burst limit for rate limiting"
  type        = number
  default     = 200
}

variable "quota_limit" {
  description = "Quota limit (requests per day)"
  type        = number
  default     = 10000
}

variable "quota_period" {
  description = "Quota period (DAY, WEEK, MONTH)"
  type        = string
  default     = "DAY"
  validation {
    condition     = contains(["DAY", "WEEK", "MONTH"], var.quota_period)
    error_message = "Quota period must be one of: DAY, WEEK, MONTH."
  }
}

# API Key Configuration
variable "api_keys" {
  description = "Map of API key configurations"
  type = map(object({
    name        = string
    description = string
    enabled     = bool
    rate_limit  = number
    quota_limit = number
  }))
  default = {
    web_app = {
      name        = "Web Application"
      description = "API key for web application"
      enabled     = true
      rate_limit  = 100
      quota_limit = 10000
    }
    mobile_app = {
      name        = "Mobile Application"
      description = "API key for mobile application"
      enabled     = true
      rate_limit  = 50
      quota_limit = 5000
    }
    admin_panel = {
      name        = "Admin Panel"
      description = "API key for admin panel"
      enabled     = true
      rate_limit  = 200
      quota_limit = 20000
    }
  }
}

# Security Headers Configuration
variable "security_headers" {
  description = "Map of security headers to add to responses"
  type        = map(string)
  default = {
    "X-Content-Type-Options" = "nosniff"
    "X-Frame-Options"        = "DENY"
    "X-XSS-Protection"       = "1; mode=block"
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains"
    "Referrer-Policy"        = "strict-origin-when-cross-origin"
    "Content-Security-Policy" = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
    "Permissions-Policy"     = "geolocation=(), microphone=(), camera=()"
  }
}

# Multiple Lambda Integrations Configuration
variable "lambda_integrations" {
  description = "Map of Lambda integrations with path-based routing"
  type = map(object({
    path_part        = string
    lambda_function_name = string
    http_methods     = list(string)
    enable_proxy     = bool
    proxy_path_part  = string
    require_api_key  = bool
    rate_limit       = number
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for integration in values(var.lambda_integrations) : 
      can(regex("^[a-zA-Z0-9_-]+$", integration.path_part))
    ])
    error_message = "Path parts must contain only alphanumeric characters, hyphens, and underscores."
  }
  
  validation {
    condition = alltrue([
      for integration in values(var.lambda_integrations) : 
      length(integration.http_methods) > 0
    ])
    error_message = "At least one HTTP method must be specified for each integration."
  }
  
  validation {
    condition = alltrue([
      for method in flatten([for integration in values(var.lambda_integrations) : integration.http_methods]) :
      contains(["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD", "ANY"], method)
    ])
    error_message = "HTTP methods must be one of: GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD, ANY."
  }
  
  validation {
    condition = alltrue([
      for method in flatten([for integration in values(var.lambda_integrations) : integration.http_methods]) :
      method != "OPTIONS"
    ])
    error_message = "OPTIONS method should not be included in http_methods as it is automatically created for CORS support."
  }
}

# Lambda Function ARNs (passed from parent module)
variable "lambda_function_arns" {
  description = "Map of Lambda function names to their invoke ARNs"
  type        = map(string)
  default     = {}
}

variable "skip_existing_methods" {
  description = "Skip creating API Gateway methods if they already exist (useful for avoiding conflicts)"
  type        = bool
  default     = false
} 
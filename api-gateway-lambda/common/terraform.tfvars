# AWS Configuration
aws_region = "us-east-2"

# Environment Configuration
environment   = "prod"
controlled_by = "terraform"
client        = "temple-project"

# Tags
tags = {
  Project     = "Temple-Project"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Application = "Temple-API"
  usage       = "common"
}

# Database Configuration
db_credentials_secret_name = "prod1db"

# API Gateway Configuration
create_api_gateway = true

api_gateway_name        = "temple-project-api-main"
api_gateway_description = "API Gateway for Temple Project with multiple Lambda functions"
api_gateway_endpoint_type = "REGIONAL"
api_gateway_stage_name  = "v0703251235"

# API Gateway Authorization
api_gateway_authorization_type = "NONE"
api_gateway_authorizer_id      = null

# API Gateway Logging
api_gateway_enable_logging     = false
api_gateway_log_retention_days = 7

# Security Configuration
enable_waf = false
enable_usage_plans = false
enable_monitoring = false

# CORS Configuration
cors_origins = [
  "*",
  "https://www.temple.com", 
  "https://admin.temple.com",
  "https://app.temple.com"
]

cors_allow_credentials = true
cors_allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD", "PATCH"]
cors_allow_headers = [
  "Content-Type", 
  "Authorization", 
  "X-Requested-With", 
  "X-API-Key", 
  "X-Amz-Date", 
  "X-Amz-Security-Token",
  "Origin",
  "Accept"
]
cors_expose_headers = [
  "X-RateLimit-Limit", 
  "X-RateLimit-Remaining", 
  "X-RateLimit-Reset", 
  "X-Process-Time"
]
cors_max_age = 86400

# Rate Limiting Configuration
rate_limit = 100      # requests per second
burst_limit = 200     # burst limit
quota_limit = 10000   # requests per day
quota_period = "DAY"

# API Keys Configuration
api_keys = {
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

# Security Headers Configuration
security_headers = {
  "X-Content-Type-Options" = "nosniff"
  "X-Frame-Options"        = "DENY"
  "X-XSS-Protection"       = "1; mode=block"
  "Strict-Transport-Security" = "max-age=31536000; includeSubDomains"
  "Referrer-Policy"        = "strict-origin-when-cross-origin"
  "Content-Security-Policy" = "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';"
  "Permissions-Policy"     = "geolocation=(), microphone=(), camera=()"
}

# Multiple Lambda Functions Configuration
lambda_functions = {
  # Authentication Service
  auth_service = {
    function_name = "np-managment-main-api"
    handler       = "main.handler"
    runtime       = "python3.11"
    memory_size   = 512
    timeout       = 30
    environment_variables = {
      ENVIRONMENT = "prod"
      LOG_LEVEL   = "INFO"
      SERVICE     = "np-management-api"
      # Security environment variables
      ALLOWED_ORIGINS = "https://temple.com,https://www.temple.com,https://admin.temple.com,https://app.temple.com"
      API_KEY_REQUIRED = "true"
      RATE_LIMIT_ENABLED = "true"
      RATE_LIMIT_REQUESTS = "100"
    }
    vpc_subnet_ids         = ["subnet-0e88b9a5f58af3830","subnet-09cdb8fbc526cbba3","subnet-0a68f373e52879c1d"]
    vpc_security_group_ids = []
    role_arn               = "arn:aws:iam::103056765659:role/aws-lambda-common-role"
    s3_bucket              = "python-api-storage-common"
    s3_key                 = "login/lambda/python-fastapi-login.zip"
    s3_object_version      = ""
    create                 = true
    delete                 = false
  }
}

# API Gateway Lambda Integrations (Path-based routing)
api_gateway_lambda_integrations = {
  # Main API endpoint
  main_api = {
    path_part        = "api/v1/login"
    lambda_function_name = "np-managment-main-api"
    http_methods     = ["GET", "POST", "PUT", "DELETE"]
    enable_proxy     = false
    proxy_path_part  = "{proxy+}"
    require_api_key  = true
    rate_limit       = 100
  }
} 
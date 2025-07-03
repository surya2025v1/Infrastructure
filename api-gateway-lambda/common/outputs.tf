# Lambda Function Outputs
output "lambda_functions" {
  description = "Map of Lambda function outputs"
  value = {
    for k, v in module.lambda_functions : k => {
      function_name = v.lambda_function_name
      function_arn  = v.lambda_function_arn
      invoke_arn    = v.lambda_invoke_arn
      security_group_id = v.lambda_security_group_id
    }
  }
}

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_function_name
  }
}

output "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_function_arn
  }
}

output "lambda_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  value = {
    for k, v in module.lambda_functions : k => v.lambda_invoke_arn
  }
}

# API Gateway Outputs
output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = module.api_gateway.api_gateway_id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway REST API"
  value       = module.api_gateway.api_gateway_arn
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = module.api_gateway.api_gateway_execution_arn
}

output "api_gateway_base_url" {
  description = "Base URL of the API Gateway stage"
  value       = module.api_gateway.api_gateway_base_url
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = module.api_gateway.api_gateway_stage_name
}

output "api_gateway_deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = module.api_gateway.api_gateway_deployment_id
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = module.api_gateway.api_gateway_stage_arn
}

output "lambda_integration_endpoints" {
  description = "Map of Lambda integration endpoints"
  value       = module.api_gateway.lambda_integration_endpoints
}

output "lambda_integration_resources" {
  description = "Map of Lambda integration resource IDs"
  value       = module.api_gateway.lambda_integration_resources
}

output "lambda_integration_proxy_resources" {
  description = "Map of Lambda integration proxy resource IDs"
  value       = module.api_gateway.lambda_integration_proxy_resources
}

# Security Outputs
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = module.api_gateway.waf_web_acl_id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = module.api_gateway.waf_web_acl_arn
}

output "usage_plan_id" {
  description = "ID of the API Gateway usage plan"
  value       = module.api_gateway.usage_plan_id
}

output "api_keys" {
  description = "Map of API keys with their details"
  value       = module.api_gateway.api_keys
  sensitive   = true
}

output "api_key_values" {
  description = "Map of API key names to their values (sensitive)"
  value       = module.api_gateway.api_key_values
  sensitive   = true
}

# Monitoring Outputs
output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms"
  value       = module.api_gateway.cloudwatch_alarms
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for API Gateway"
  value       = module.api_gateway.cloudwatch_log_group_name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for API Gateway"
  value       = module.api_gateway.cloudwatch_log_group_arn
}

output "cloudwatch_role_arn" {
  description = "ARN of the IAM role for CloudWatch logging"
  value       = module.api_gateway.cloudwatch_role_arn
}

# Security Configuration Outputs
output "cors_configuration" {
  description = "CORS configuration details"
  value       = module.api_gateway.cors_configuration
}

output "rate_limiting_configuration" {
  description = "Rate limiting configuration details"
  value       = module.api_gateway.rate_limiting_configuration
}

output "security_headers" {
  description = "Security headers configuration"
  value       = module.api_gateway.security_headers
}

# Combined Outputs
output "api_endpoints" {
  description = "Map of API endpoints for each Lambda integration"
  value = {
    for k, v in module.api_gateway.lambda_integration_endpoints : k => {
      path_part = v.path_part
      endpoint  = v.endpoint
      proxy_endpoint = v.proxy_endpoint
      lambda_function_name = v.lambda_function_name
      http_methods = v.http_methods
      require_api_key = v.require_api_key
      rate_limit = v.rate_limit
      documentation_url = "${v.endpoint}/docs"
      redoc_url = "${v.endpoint}/redoc"
    }
  }
}

output "api_documentation_urls" {
  description = "Map of API documentation URLs for each Lambda integration"
  value = {
    for k, v in module.api_gateway.lambda_integration_endpoints : k => {
      swagger_ui = "${v.endpoint}/docs"
      redoc = "${v.endpoint}/redoc"
    }
  }
}

# Security Summary
output "security_summary" {
  description = "Summary of security configurations"
  value = {
    waf_enabled = var.enable_waf
    usage_plans_enabled = var.enable_usage_plans
    monitoring_enabled = var.enable_monitoring
    cors_origins_count = length(var.cors_origins)
    rate_limit = var.rate_limit
    burst_limit = var.burst_limit
    quota_limit = var.quota_limit
    api_keys_count = length(var.api_keys)
    security_headers_count = length(var.security_headers)
  }
}

# Deployment Information
output "deployment_info" {
  description = "Deployment information and next steps"
  value = {
    api_url = module.api_gateway.api_gateway_base_url
    stage_name = module.api_gateway.api_gateway_stage_name
    waf_status = var.enable_waf ? "Enabled" : "Disabled"
    api_keys_status = var.enable_usage_plans ? "Enabled" : "Disabled"
    monitoring_status = var.enable_monitoring ? "Enabled" : "Disabled"
    cors_origins = var.cors_origins
    rate_limiting = {
      rate_limit = var.rate_limit
      burst_limit = var.burst_limit
      quota_limit = var.quota_limit
      quota_period = var.quota_period
    }
    next_steps = [
      "Test API endpoints with API keys (if enabled)",
      "Monitor CloudWatch logs and alarms",
      "Verify CORS configuration in browser",
      "Check WAF rules and metrics",
      "Review security headers in responses"
    ]
  }
} 
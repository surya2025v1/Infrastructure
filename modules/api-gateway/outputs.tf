output "api_gateway_id" {
  description = "ID of the API Gateway REST API"
  value       = var.create ? aws_api_gateway_rest_api.this[0].id : null
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway REST API"
  value       = var.create ? aws_api_gateway_rest_api.this[0].arn : null
}

output "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway REST API"
  value       = var.create ? aws_api_gateway_rest_api.this[0].execution_arn : null
}

output "api_gateway_root_resource_id" {
  description = "Root resource ID of the API Gateway REST API"
  value       = var.create ? aws_api_gateway_rest_api.this[0].root_resource_id : null
}

output "api_gateway_base_url" {
  description = "Base URL of the API Gateway stage"
  value       = var.create ? "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}" : null
}

output "api_gateway_stage_name" {
  description = "Name of the API Gateway stage"
  value       = var.create ? var.stage_name : null
}

output "api_gateway_deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = var.create ? aws_api_gateway_deployment.this[0].id : null
}

output "api_gateway_stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = var.create ? (local.should_create_stage ? aws_api_gateway_stage.this[0].arn : "arn:aws:apigateway:${data.aws_region.current.name}::/restapis/${aws_api_gateway_rest_api.this[0].id}/stages/${var.stage_name}") : null
}

output "api_gateway_stage_exists" {
  description = "Whether the API Gateway stage was created or already existed"
  value       = var.create ? !local.should_create_stage : false
}

output "lambda_integration_endpoints" {
  description = "Map of Lambda integration endpoints"
  value = var.create ? {
    for k, v in var.lambda_integrations : k => {
      path_part = v.path_part
      endpoint  = "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/${v.path_part}"
      proxy_endpoint = v.enable_proxy ? "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/${v.path_part}/${v.proxy_path_part}" : null
      lambda_function_name = v.lambda_function_name
      http_methods = v.http_methods
      require_api_key = v.require_api_key
      rate_limit = v.rate_limit
    }
  } : {}
}

output "lambda_integration_resources" {
  description = "Map of Lambda integration resource IDs"
  value = var.create ? {
    for k, v in aws_api_gateway_resource.lambda_resources : k => v.id
  } : {}
}

output "lambda_integration_proxy_resources" {
  description = "Map of Lambda integration proxy resource IDs"
  value = var.create ? {
    for k, v in aws_api_gateway_resource.lambda_proxy_resources : k => v.id
  } : {}
}

# Security Outputs
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = var.create && var.enable_waf ? aws_wafv2_web_acl.api_gateway[0].id : null
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = var.create && var.enable_waf ? aws_wafv2_web_acl.api_gateway[0].arn : null
}

output "usage_plan_id" {
  description = "ID of the API Gateway usage plan"
  value       = var.create && var.enable_usage_plans ? aws_api_gateway_usage_plan.main[0].id : null
}

output "api_keys" {
  description = "Map of API keys with their values"
  value = var.create && var.enable_usage_plans ? {
    for k, v in aws_api_gateway_api_key.keys : k => {
      id = v.id
      name = v.name
      description = v.description
      enabled = v.enabled
      value = v.value
      created_date = v.created_date
    }
  } : {}
  sensitive = true
}

output "api_key_values" {
  description = "Map of API key names to their values (sensitive)"
  value = var.create && var.enable_usage_plans ? {
    for k, v in aws_api_gateway_api_key.keys : k => v.value
  } : {}
  sensitive = true
}

# Monitoring Outputs
output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarms"
  value = var.create && var.enable_monitoring ? {
    api_errors = aws_cloudwatch_metric_alarm.api_errors[0].arn
    api_latency = aws_cloudwatch_metric_alarm.api_latency[0].arn
    api_requests = aws_cloudwatch_metric_alarm.api_requests[0].arn
  } : {}
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for API Gateway"
  value       = var.create && var.enable_logging ? aws_cloudwatch_log_group.api_gw[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for API Gateway"
  value       = var.create && var.enable_logging ? aws_cloudwatch_log_group.api_gw[0].arn : null
}

output "cloudwatch_role_arn" {
  description = "ARN of the IAM role for CloudWatch logging"
  value       = var.create && var.enable_logging ? aws_iam_role.cloudwatch[0].arn : null
}

# Security Configuration Outputs
output "cors_configuration" {
  description = "CORS configuration details"
  value = var.create ? {
    allowed_origins = var.cors_origins
    allow_credentials = var.cors_allow_credentials
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    expose_headers = var.cors_expose_headers
    max_age = var.cors_max_age
  } : {
    allowed_origins = []
    allow_credentials = false
    allow_methods = []
    allow_headers = []
    expose_headers = []
    max_age = 0
  }
}

output "rate_limiting_configuration" {
  description = "Rate limiting configuration details"
  value = var.create ? {
    rate_limit = var.rate_limit
    burst_limit = var.burst_limit
    quota_limit = var.quota_limit
    quota_period = var.quota_period
  } : {
    rate_limit = 0
    burst_limit = 0
    quota_limit = 0
    quota_period = "DAY"
  }
}

output "security_headers" {
  description = "Security headers configuration"
  value = var.create ? var.security_headers : {
    "X-Content-Type-Options" = ""
    "X-Frame-Options" = ""
    "X-XSS-Protection" = ""
    "Strict-Transport-Security" = ""
    "Referrer-Policy" = ""
    "Content-Security-Policy" = ""
    "Permissions-Policy" = ""
  }
}

# Documentation URLs
output "api_documentation_urls" {
  description = "API documentation URLs"
  value = var.create ? {
    swagger_ui = "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/docs"
    redoc = "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/redoc"
    openapi_json = "https://${aws_api_gateway_rest_api.this[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}/openapi.json"
  } : {}
} 
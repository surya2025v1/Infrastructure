# Data source for current AWS region
data "aws_region" "current" {}

# Local values to handle existing stages
locals {
  # Since we can't check if stage exists via data source, we'll use a variable to control behavior
  should_create_stage = var.create && var.ignore_existing_stage
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  count = var.create ? 1 : 0

  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

# API Gateway Resources for each Lambda integration
resource "aws_api_gateway_resource" "lambda_resources" {
  for_each = var.create ? var.lambda_integrations : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  parent_id   = aws_api_gateway_rest_api.this[0].root_resource_id
  path_part   = each.value.path_part
}

# API Gateway Resources for proxy paths (if enabled)
resource "aws_api_gateway_resource" "lambda_proxy_resources" {
  for_each = var.create ? {
    for k, v in var.lambda_integrations : k => v
    if v.enable_proxy
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  parent_id   = aws_api_gateway_resource.lambda_resources[each.key].id
  path_part   = each.value.proxy_path_part
}

# API Gateway Methods for each Lambda integration
resource "aws_api_gateway_method" "lambda_methods" {
  for_each = var.create ? {
    for item in flatten([
      for integration_key, integration in var.lambda_integrations : [
        for method in integration.http_methods : {
          integration_key = integration_key
          http_method     = method
        }
      ]
    ]) : "${item.integration_key}-${item.http_method}" => item
  } : {}

  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  resource_id   = aws_api_gateway_resource.lambda_resources[each.value.integration_key].id
  http_method   = each.value.http_method
  authorization = var.authorization_type
  authorizer_id = var.authorizer_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# API Gateway Methods for proxy paths
resource "aws_api_gateway_method" "lambda_proxy_methods" {
  for_each = var.create ? {
    for item in flatten([
      for integration_key, integration in var.lambda_integrations : [
        for method in integration.http_methods : {
          integration_key = integration_key
          http_method     = method
        }
      ]
      if integration.enable_proxy
    ]) : "${item.integration_key}-${item.http_method}" => item
  } : {}

  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  resource_id   = aws_api_gateway_resource.lambda_proxy_resources[each.value.integration_key].id
  http_method   = each.value.http_method
  authorization = var.authorization_type
  authorizer_id = var.authorizer_id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

# OPTIONS method for CORS on main resources
resource "aws_api_gateway_method" "lambda_options_methods" {
  for_each = var.create ? var.lambda_integrations : {}

  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  resource_id   = aws_api_gateway_resource.lambda_resources[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for CORS on proxy resources
resource "aws_api_gateway_method" "lambda_proxy_options_methods" {
  for_each = var.create ? {
    for k, v in var.lambda_integrations : k => v
    if v.enable_proxy
  } : {}

  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  resource_id   = aws_api_gateway_resource.lambda_proxy_resources[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"

  # Only create if the proxy resource exists and doesn't already have OPTIONS
  depends_on = [aws_api_gateway_resource.lambda_proxy_resources]
}

# Lambda Integrations for main resources
resource "aws_api_gateway_integration" "lambda_integrations" {
  for_each = var.create ? {
    for item in flatten([
      for integration_key, integration in var.lambda_integrations : [
        for method in integration.http_methods : {
          integration_key = integration_key
          http_method     = method
        }
      ]
    ]) : "${item.integration_key}-${item.http_method}" => item
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_resources[each.value.integration_key].id
  http_method = aws_api_gateway_method.lambda_methods[each.key].http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_function_arns[var.lambda_integrations[each.value.integration_key].lambda_function_name]
}

# Lambda Integrations for proxy resources
resource "aws_api_gateway_integration" "lambda_proxy_integrations" {
  for_each = var.create ? {
    for item in flatten([
      for integration_key, integration in var.lambda_integrations : [
        for method in integration.http_methods : {
          integration_key = integration_key
          http_method     = method
        }
      ]
      if integration.enable_proxy
    ]) : "${item.integration_key}-${item.http_method}" => item
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_proxy_resources[each.value.integration_key].id
  http_method = aws_api_gateway_method.lambda_proxy_methods[each.key].http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.lambda_function_arns[var.lambda_integrations[each.value.integration_key].lambda_function_name]
}

# CORS Integration for main resources
resource "aws_api_gateway_integration" "lambda_options_integrations" {
  for_each = var.create ? var.lambda_integrations : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_options_methods[each.key].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Integration for proxy resources
resource "aws_api_gateway_integration" "lambda_proxy_options_integrations" {
  for_each = var.create ? {
    for k, v in var.lambda_integrations : k => v
    if v.enable_proxy
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_proxy_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_proxy_options_methods[each.key].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS Method Response for main resources
resource "aws_api_gateway_method_response" "lambda_options_method_responses" {
  for_each = var.create ? var.lambda_integrations : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_options_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Access-Control-Max-Age" = true
  }
}

# CORS Method Response for proxy resources
resource "aws_api_gateway_method_response" "lambda_proxy_options_method_responses" {
  for_each = var.create ? {
    for k, v in var.lambda_integrations : k => v
    if v.enable_proxy
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_proxy_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_proxy_options_methods[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Credentials" = true
    "method.response.header.Access-Control-Max-Age" = true
  }
}

# CORS Integration Response for main resources
resource "aws_api_gateway_integration_response" "lambda_options_integration_responses" {
  for_each = var.create ? var.lambda_integrations : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_options_methods[each.key].http_method
  status_code = aws_api_gateway_method_response.lambda_options_method_responses[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_origins)}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'${var.cors_allow_credentials}'"
    "method.response.header.Access-Control-Max-Age" = "'${var.cors_max_age}'"
  }
}

# CORS Integration Response for proxy resources
resource "aws_api_gateway_integration_response" "lambda_proxy_options_integration_responses" {
  for_each = var.create ? {
    for k, v in var.lambda_integrations : k => v
    if v.enable_proxy
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  resource_id = aws_api_gateway_resource.lambda_proxy_resources[each.key].id
  http_method = aws_api_gateway_method.lambda_proxy_options_methods[each.key].http_method
  status_code = aws_api_gateway_method_response.lambda_proxy_options_method_responses[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_origins)}'"
    "method.response.header.Access-Control-Allow-Credentials" = "'${var.cors_allow_credentials}'"
    "method.response.header.Access-Control-Max-Age" = "'${var.cors_max_age}'"
  }
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "apigw_permissions" {
  for_each = var.create ? var.lambda_integrations : {}

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.this[0].execution_arn}/*/*"

  # Add depends_on to ensure Lambda function exists before creating permission
  depends_on = [aws_api_gateway_rest_api.this]
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  count = var.create ? 1 : 0

  depends_on = [
    aws_api_gateway_integration.lambda_integrations,
    aws_api_gateway_integration.lambda_proxy_integrations,
    aws_api_gateway_integration.lambda_options_integrations,
    aws_api_gateway_integration.lambda_proxy_options_integrations,
    aws_api_gateway_integration_response.lambda_options_integration_responses,
    aws_api_gateway_integration_response.lambda_proxy_options_integration_responses,
    aws_lambda_permission.apigw_permissions,
  ]

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  stage_name  = var.stage_name

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  count = local.should_create_stage ? 1 : 0

  deployment_id = aws_api_gateway_deployment.this[0].id
  rest_api_id   = aws_api_gateway_rest_api.this[0].id
  stage_name    = var.stage_name

  # Enable detailed CloudWatch logging only if logging is enabled
  dynamic "access_log_settings" {
    for_each = var.enable_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
        integrationLatency = "$context.integrationLatency"
        responseLatency    = "$context.responseLatency"
        userAgent      = "$context.identity.userAgent"
        errorMessage   = "$context.error.message"
        errorResponseType = "$context.error.responseType"
      })
    }
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

# Method Settings for API Gateway Stage
resource "aws_api_gateway_method_settings" "main" {
  count = var.create ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this[0].id
  stage_name  = var.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = var.enable_monitoring
    logging_level   = var.enable_monitoring ? "INFO" : "OFF"
    data_trace_enabled = false
  }

  depends_on = [aws_api_gateway_stage.this]
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gw" {
  count = var.create && var.enable_logging ? 1 : 0

  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

# IAM Role for API Gateway CloudWatch Logging
resource "aws_iam_role" "cloudwatch" {
  count = var.create && var.enable_logging ? 1 : 0

  name = "${var.api_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for CloudWatch Logging
resource "aws_iam_role_policy" "cloudwatch" {
  count = var.create && var.enable_logging ? 1 : 0

  name = "${var.api_name}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# WAF Web ACL for API Gateway protection
resource "aws_wafv2_web_acl" "api_gateway" {
  count = var.create && var.enable_waf ? 1 : 0
  
  name        = "${var.api_name}-waf"
  description = "WAF for ${var.api_name} API Gateway"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = var.burst_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitRule"
      sampled_requests_enabled  = true
    }
  }

  # AWS managed rules for common threats
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled  = true
    }
  }

  # SQL injection protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "${var.api_name}-waf"
    sampled_requests_enabled  = true
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

# Associate WAF with API Gateway Stage
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.create && var.enable_waf ? 1 : 0
  
  resource_arn = aws_api_gateway_stage.this[0].arn
  web_acl_arn  = aws_wafv2_web_acl.api_gateway[0].arn
}

# API Gateway Usage Plan
resource "aws_api_gateway_usage_plan" "main" {
  count = var.create && var.enable_usage_plans ? 1 : 0
  
  name         = "${var.api_name}-usage-plan"
  description  = "Usage plan for ${var.api_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.this[0].id
    stage  = aws_api_gateway_stage.this[0].stage_name
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }

  throttle_settings {
    burst_limit = var.burst_limit
    rate_limit  = var.rate_limit
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

# API Keys for different client types
resource "aws_api_gateway_api_key" "keys" {
  for_each = var.create && var.enable_usage_plans ? var.api_keys : {}

  name        = "${var.api_name}-${each.key}-key"
  description = each.value.description
  enabled     = each.value.enabled

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
    KeyType       = each.key
  })
}

# Usage Plan Keys
resource "aws_api_gateway_usage_plan_key" "keys" {
  for_each = var.create && var.enable_usage_plans ? var.api_keys : {}

  key_id        = aws_api_gateway_api_key.keys[each.key].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[0].id
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  count = var.create && var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.api_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "API Gateway 5XX errors for ${var.api_name}"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ApiName = aws_api_gateway_rest_api.this[0].name
    Stage   = aws_api_gateway_stage.this[0].stage_name
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

resource "aws_cloudwatch_metric_alarm" "api_latency" {
  count = var.create && var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.api_name}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000"  # 5 seconds
  alarm_description   = "API Gateway high latency for ${var.api_name}"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ApiName = aws_api_gateway_rest_api.this[0].name
    Stage   = aws_api_gateway_stage.this[0].stage_name
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

resource "aws_cloudwatch_metric_alarm" "api_requests" {
  count = var.create && var.enable_monitoring ? 1 : 0
  
  alarm_name          = "${var.api_name}-high-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Count"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000"  # 1000 requests per 5 minutes
  alarm_description   = "API Gateway high request volume for ${var.api_name}"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ApiName = aws_api_gateway_rest_api.this[0].name
    Stage   = aws_api_gateway_stage.this[0].stage_name
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
} 
# Security Group for Lambda (if VPC is configured)
resource "aws_security_group" "lambda" {
  count = var.create && length(var.vpc_subnet_ids) > 0 ? 1 : 0

  name_prefix = "${var.function_name}-lambda-"
  description = "Security group for ${var.function_name} Lambda function"
  vpc_id      = data.aws_subnet.lambda_subnet[0].vpc_id

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
    Name          = "${var.function_name}-lambda-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Data source to get VPC ID from subnet
data "aws_subnet" "lambda_subnet" {
  count = var.create && length(var.vpc_subnet_ids) > 0 ? 1 : 0
  id    = var.vpc_subnet_ids[0]
}

# Lambda Function
resource "aws_lambda_function" "this" {
  count = var.create ? 1 : 0

  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  memory_size   = var.memory_size
  timeout       = var.timeout

  # Use S3 deployment if bucket is provided, otherwise use local file
  s3_bucket = var.s3_bucket != "" ? var.s3_bucket : null
  s3_key    = var.s3_key != "" ? var.s3_key : null
  s3_object_version = var.s3_object_version != "" ? var.s3_object_version : null

  # Use local file if S3 not configured
  filename = var.s3_bucket == "" ? "${path.module}/placeholder.zip" : null

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    for_each = length(var.vpc_subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = concat([aws_security_group.lambda[0].id], var.vpc_security_group_ids)
    }
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
} 
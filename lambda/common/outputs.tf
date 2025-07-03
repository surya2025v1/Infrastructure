output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = var.create ? module.lambda.lambda_function_name : null
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = var.create ? module.lambda.lambda_function_arn : null
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = var.create ? module.lambda.lambda_invoke_arn : null
}

output "lambda_security_group_id" {
  description = "ID of the Lambda security group (if VPC is configured)"
  value       = var.create ? module.lambda.lambda_security_group_id : null
}

output "db_credentials_secret_info" {
  description = "Secrets Manager information for database credentials and connection info"
  value = var.create ? {
    secret_name = data.aws_secretsmanager_secret.db_credentials.name
    secret_arn  = data.aws_secretsmanager_secret.db_credentials.arn
  } : null
} 
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = var.create ? aws_lambda_function.this[0].function_name : null
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = var.create ? aws_lambda_function.this[0].arn : null
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = var.create ? aws_lambda_function.this[0].invoke_arn : null
}

output "lambda_security_group_id" {
  description = "ID of the Lambda security group (if VPC is configured)"
  value       = var.create && length(var.vpc_subnet_ids) > 0 ? aws_security_group.lambda[0].id : null
} 
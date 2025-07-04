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
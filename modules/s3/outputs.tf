output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.create ? aws_s3_bucket.api_storage[0].bucket : null
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.create ? aws_s3_bucket.api_storage[0].arn : null
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.create ? aws_s3_bucket.api_storage[0].id : null
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = var.create ? aws_s3_bucket.api_storage[0].region : null
} 
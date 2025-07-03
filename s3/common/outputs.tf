output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.create ? module.s3_api_storage.bucket_name : null
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.create ? module.s3_api_storage.bucket_arn : null
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.create ? module.s3_api_storage.bucket_id : null
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = var.create ? module.s3_api_storage.bucket_region : null
} 
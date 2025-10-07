# Outputs for S3 Static Website Module

output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.website_bucket.bucket_domain_name
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website_bucket.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = aws_s3_bucket_website_configuration.website_bucket.website_domain
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website_distribution[0].id : null
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website_distribution[0].domain_name : null
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website_distribution[0].arn : null
}

output "cloudfront_distribution_status" {
  description = "The current status of the CloudFront distribution"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website_distribution[0].status : null
}

output "cloudfront_hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an Alias Resource Record Set to"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website_distribution[0].hosted_zone_id : null
}

output "cloudfront_distribution_url" {
  description = "The URL of the CloudFront distribution"
  value       = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website_distribution[0].domain_name}" : null
}

output "cloudfront_origin_access_identity" {
  description = "The CloudFront origin access identity (if using OAI)"
  value       = null  # Not using OAI in this configuration, using website endpoint instead
}

output "website_urls" {
  description = "Available website URLs (S3 direct and CloudFront if enabled)"
  value = {
    s3_website_url = "http://${aws_s3_bucket_website_configuration.website_bucket.website_endpoint}"
    cloudfront_url = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website_distribution[0].domain_name}" : null
  }
} 
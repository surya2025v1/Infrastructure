# Outputs for website-1 bucket

output "bucket_id" {
  description = "The name of the S3 bucket"
  value       = module.s3_static_website.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.s3_static_website.bucket_arn
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = module.s3_static_website.website_endpoint
}

output "website_domain" {
  description = "The domain of the website endpoint"
  value       = module.s3_static_website.website_domain
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = module.s3_static_website.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = module.s3_static_website.cloudfront_domain_name
} 
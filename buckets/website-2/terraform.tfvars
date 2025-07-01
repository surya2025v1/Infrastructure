# Configuration for website-2 bucket

aws_region = "us-east-1"
bucket_name = "website-2-static-site"
environment = "prod"



# Versioning configuration
enable_versioning = true

# CloudFront configuration
enable_cloudfront = true
cloudfront_price_class = "PriceClass_200"
cloudfront_aliases = []

# Additional tags
tags = {
  Project     = "StaticWebsites"
  Environment = "prod"
  Owner       = "DevOps"
  Purpose     = "Website-2"
  Production  = "true"
}

# Tag configuration
controlled_by = "Terraform"
client = "TBD" 
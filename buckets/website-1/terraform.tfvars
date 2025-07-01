# Configuration for website-1 bucket

aws_region = "us-east-1"
bucket_name = "website-1-static-site"
environment = "dev"



# Versioning configuration
enable_versioning = false

# CloudFront configuration
enable_cloudfront = false
cloudfront_price_class = "PriceClass_100"
cloudfront_aliases = []

# Additional tags
tags = {
  Project     = "StaticWebsites"
  Environment = "dev"
  Owner       = "DevOps"
  Purpose     = "Website-1"
  controlled_by = "Terraform"
  client = "Web_managment"
}

client = "SV_temple"

# Pipeline control flags
create = true
delete = false 
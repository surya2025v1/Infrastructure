# Configuration for website-1 bucket

aws_region = "us-east-2"
bucket_name = "svtemple.org1"
environment = "prod"



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
  client = "svtemple.org"
}

client ="svtemple.org"

# Pipeline control flags
create = true
delete = false 
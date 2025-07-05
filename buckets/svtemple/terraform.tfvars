aws_region = "us-east-2"
bucket_name = "svtemple-test"
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
  Purpose     = "svtemple"
  controlled_by = "Terraform"
}

client ="svtemple-test"  

# Pipeline control flags
create = true
delete = false 

# AWS region for the S3 bucket
aws_region = "us-east-2"
environment = "prod"

# S3 bucket configuration
bucket_name = "python-api-storage-svtemple"
enable_versioning = true

# Additional tags
tags = {
  Project       = "Python-API-Storage"
  Environment   = "dev"
  Owner         = "DevOps"
  Purpose       = "API-Storage"
  controlled_by = "Terraform"
  owner         = "web-application"
}

usage  = "global"
client = "global"

# Pipeline control flags
create = true
delete = false 
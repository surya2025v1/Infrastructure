# AWS region for the Lambda function
aws_region = "us-east-2"
environment = "dev"

# Lambda function configuration
function_name = "fastapi-lambda-main"
handler       = "main.handler"
runtime       = "python3.11"

# Lambda function settings
memory_size = 128
timeout     = 30

# Environment variables
environment_variables = {
  ENV = "dev"
  # All DB connection info is now in the prod1db secret
}

db_credentials_secret_name = "prod1db"

# AWS Secrets Manager configuration
# Using existing secrets: common_db_username and common_db_password
# db_username_secret_name = "common_db_username"  # default value
# db_password_secret_name = "common_db_password"  # default value

# VPC configuration (optional - leave empty for public Lambda)
vpc_subnet_ids         = ["subnet-0e88b9a5f58af3830","subnet-09cdb8fbc526cbba3","subnet-0a68f373e52879c1d"]
vpc_security_group_ids = []

# IAM role ARN for Lambda execution (created externally)
role_arn = "arn:aws:iam::103056765659:role/aws-lambda-common-role"

# Additional tags
tags = {
  Project       = "FastAPI-Lambda"
  Environment   = "dev"
  Owner         = "DevOps"
  Purpose       = "API-Service"
  controlled_by = "Terraform"
  owner         = "web-application"
}

usage  = "global"
client = "global"

# Pipeline control flags
create = true
delete = false

# S3 deployment package for Lambda
s3_bucket = "python-api-storage-common"
s3_key    = "login/lambda/python-fastapi-login.zip"
#s3_object_version = ""

# RDS MySQL connection
rds_instance_name = "prod1-mysql-db" 
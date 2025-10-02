# Lambda Module with RDS MySQL Connection and ECR Support

This Terraform module creates an AWS Lambda function with optional RDS MySQL connection capabilities using AWS Secrets Manager, and supports both S3/ZIP packages and ECR container images.

## Features

- Create Lambda functions with custom runtime and configuration
- Support for both S3/ZIP packages (default) and ECR container images
- Automatic RDS MySQL connection setup using AWS Secrets Manager
- VPC configuration support
- Security group management for Lambda-RDS communication
- Environment variable injection for database connection details

## RDS MySQL Connection

The module supports automatic RDS MySQL connection configuration by reading connection details from AWS Secrets Manager.

### Secret Format

The secret in AWS Secrets Manager should contain the following JSON structure:

```json
{
  "host": "your-rds-endpoint.region.rds.amazonaws.com",
  "port": "3306",
  "database": "your_database_name",
  "username": "your_username",
  "password": "your_password"
}
```

Alternative field names are also supported:
- `host` or `endpoint`
- `database` or `dbname`
- `port` (defaults to 3306 if not specified)

## Package Types

The module supports two package types:

1. **S3/ZIP Package (Default)**: Traditional Lambda deployment packages stored in S3 or local ZIP files
2. **ECR Container Image**: Container images stored in Amazon Elastic Container Registry (ECR)

By default, the module uses S3/ZIP packages to maintain backward compatibility with existing deployments.

## Usage

### Basic Lambda Function with S3/ZIP Package (Default)

```hcl
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "my-lambda-function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role_arn      = aws_iam_role.lambda_role.arn
  
  environment = "dev"
  client      = "myclient"
}
```

### Lambda Function with ECR Container Image

```hcl
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "my-lambda-function"
  role_arn      = aws_iam_role.lambda_role.arn
  
  # Enable ECR container image
  use_ecr_image = true
  ecr_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda-repo:latest"
  
  # When using ECR images, handler and runtime are not required
  # The container image must include the Lambda runtime interface client
  
  environment = "dev"
  client      = "myclient"
}
```

### Lambda Function with S3 Package

```hcl
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "my-lambda-function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role_arn      = aws_iam_role.lambda_role.arn
  
  # S3 deployment package configuration
  s3_bucket = "my-lambda-deployments"
  s3_key    = "functions/my-function.zip"
  s3_object_version = "1" # Optional: specific version
  
  environment = "dev"
  client      = "myclient"
}
```

### Lambda Function with RDS Connection

```hcl
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "my-lambda-function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role_arn      = aws_iam_role.lambda_role.arn
  
  # Enable RDS connection
  enable_rds_connection = true
  rds_secret_name       = "my-rds-connection-secret"
  rds_secret_region     = "us-east-1"
  
  # VPC configuration (required for RDS connection)
  vpc_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  environment = "dev"
  client      = "myclient"
}
```

### Lambda Function with Custom RDS Configuration

```hcl
module "lambda" {
  source = "./modules/lambda"
  
  function_name = "my-lambda-function"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role_arn      = aws_iam_role.lambda_role.arn
  
  # RDS configuration
  enable_rds_connection    = true
  rds_secret_name         = "my-rds-connection-secret"
  rds_connection_timeout  = 60
  rds_max_connections     = 20
  
  # VPC configuration
  vpc_subnet_ids = ["subnet-12345678", "subnet-87654321"]
  
  # Additional environment variables
  environment_variables = {
    LOG_LEVEL = "DEBUG"
    API_VERSION = "v1"
  }
  
  environment = "dev"
  client      = "myclient"
}
```

## Environment Variables

When RDS connection is enabled, the following environment variables are automatically added to the Lambda function:

- `RDS_SECRET_NAME`: The name of the secret used for connection
- `RDS_SECRET_REGION`: The AWS region where the secret is stored
- `RDS_HOST`: The RDS endpoint/host
- `RDS_PORT`: The RDS port (default: 3306)
- `RDS_DATABASE`: The database name
- `RDS_USERNAME`: The database username
- `RDS_PASSWORD`: The database password
- `RDS_CONNECTION_TIMEOUT`: Connection timeout in seconds
- `RDS_MAX_CONNECTIONS`: Maximum number of connections in the pool

## ECR Configuration

When using ECR container images:

- Set `use_ecr_image = true`
- Provide the full ECR image URI in `ecr_image_uri`
- Ensure the container image includes the Lambda runtime interface client
- The Lambda execution role must have appropriate ECR permissions
- Handler and runtime are not required for container images

### ECR IAM Permissions

The Lambda execution role must have the following permissions for ECR access:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  }
}
```

## Required IAM Permissions

The Lambda execution role must have the following permissions for RDS connection:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:your-secret-name*"
    }
  ]
}
```

## Security

- Database credentials are stored securely in AWS Secrets Manager
- Lambda function runs in VPC with restricted access
- Security groups are automatically configured for Lambda-RDS communication
- No sensitive data is stored in environment variables (only secret references)

## Outputs

- `lambda_function_name`: Name of the Lambda function
- `lambda_function_arn`: ARN of the Lambda function
- `lambda_invoke_arn`: Invoke ARN of the Lambda function
- `lambda_security_group_id`: ID of the Lambda security group
- `rds_secret_name`: Name of the RDS secret used for connection
- `rds_connection_enabled`: Whether RDS connection is enabled
- `rds_host`: RDS host endpoint (from secret)
- `rds_port`: RDS port (from secret)
- `rds_database`: RDS database name (from secret)

## Variables

### Required Variables

- `function_name` - Name of the Lambda function
- `role_arn` - IAM role ARN for Lambda execution

### Optional Variables

#### Package Configuration
- `use_ecr_image` - Enable ECR container images (default: false)
- `ecr_image_uri` - Full ECR image URI (required when use_ecr_image = true)
- `lambda_package_type` - Package type: "Zip" or "Image" (default: "Zip")

#### Traditional Package Configuration (when use_ecr_image = false)
- `handler` - Lambda function entrypoint (default: "main.handler")
- `runtime` - Lambda runtime version (default: "python3.11")
- `s3_bucket` - S3 bucket for deployment package (optional)
- `s3_key` - S3 key/path to deployment package (optional)
- `s3_object_version` - S3 object version (optional)

#### Function Configuration
- `memory_size` - Memory size in MB (default: 512)
- `timeout` - Timeout in seconds (default: 30)
- `environment_variables` - Map of environment variables

#### RDS Configuration
- `rds_secret_name` - AWS Secrets Manager secret name for RDS connection

#### Tags and Metadata
- `tags` - Map of tags for resources
- `environment` - Environment name (default: "dev")
- `controlled_by` - Control tagging (default: "Terraform")
- `client` - Client name (default: "TBD")

#### Control Flags
- `create` - Enable resource creation (default: true)
- `delete` - Enable resource deletion (default: false)

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0
- VPC configuration when using RDS connection
- AWS Secrets Manager secret with RDS connection details
- For ECR images: Container image must include Lambda runtime interface client 
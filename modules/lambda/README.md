# Lambda Module with RDS MySQL Connection

This Terraform module creates an AWS Lambda function with optional RDS MySQL connection capabilities using AWS Secrets Manager.

## Features

- Create Lambda functions with custom runtime and configuration
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

## Usage

### Basic Lambda Function

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

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0
- VPC configuration when using RDS connection
- AWS Secrets Manager secret with RDS connection details 
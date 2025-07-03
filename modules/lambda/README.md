# Lambda Module

This Terraform module deploys an AWS Lambda function (Python 3.11, FastAPI-ready) with security group and conditional creation/deletion.

## Features

- **Lambda Function**: Python 3.11 runtime with configurable memory and timeout
- **Security Group**: VPC security group with outbound access (if VPC configured)
- **Conditional Creation**: Use `create` flag to control deployment
- **Comprehensive Tagging**: Consistent tagging across all resources
- **External IAM Role**: Uses externally created IAM role for Lambda execution

## Usage Example

```hcl
module "lambda" {
  source = "../../modules/lambda"
  
  function_name = "my-fastapi-lambda"
  environment   = "prod"
  handler       = "main.handler"
  runtime       = "python3.11"
  role_arn      = "arn:aws:iam::123456789012:role/lambda-exec-role"
  
  environment_variables = {
    ENV = "prod"
  }
  
  memory_size = 512
  timeout     = 30
  
  # Optional VPC configuration
  vpc_subnet_ids         = ["subnet-xxxxxx"]
  vpc_security_group_ids = ["sg-xxxxxx"]
  
  tags = {
    Project     = "FastAPI-Lambda"
    Environment = "prod"
    Owner       = "DevOps"
    Purpose     = "API-Service"
  }
  
  client = "myapp.com"
  create = true
  delete = false
}
```

## Required Variables
- `function_name`: Name of the Lambda function
- `role_arn`: IAM role ARN for Lambda execution (created externally)

## Optional Variables
- `environment`: Environment name (default: "dev")
- `handler`: Entrypoint handler (default: "main.handler")
- `runtime`: Lambda runtime (default: "python3.11")
- `environment_variables`: Map of environment variables (default: {})
- `memory_size`: Memory in MB (default: 512)
- `timeout`: Timeout in seconds (default: 30)
- `vpc_subnet_ids`: List of subnet IDs for VPC config (default: [])
- `vpc_security_group_ids`: List of additional security group IDs (default: [])
- `tags`: Map of tags to assign to resources (default: {})
- `controlled_by`: Tag indicating what controls this resource (default: "Terraform")
- `client`: Client name for the project (default: "TBD")
- `create`: Flag to control Lambda function creation (default: true)
- `delete`: Flag to control Lambda function deletion (default: false)

## Outputs
- `lambda_function_name`: Name of the Lambda function (null if not created)
- `lambda_function_arn`: ARN of the Lambda function (null if not created)
- `lambda_invoke_arn`: Invoke ARN of the Lambda function (null if not created)
- `lambda_security_group_id`: ID of the Lambda security group (null if not VPC)

## Security Features

### IAM Role (External)
- Must be created externally with appropriate permissions
- Should include basic Lambda execution permissions
- Should include VPC access permissions (if VPC configured)
- Follows least privilege principle

### Security Group (VPC)
- Outbound access to all destinations
- No inbound rules (Lambda doesn't accept direct connections)
- Lifecycle management for updates

## Notes
- The Lambda function will only be created if `create = true`
- Source code deployment should be handled separately via CI/CD or manual upload
- Tags are automatically merged with environment, controlled_by, and client tags
- VPC configuration is optional - leave empty for public Lambda deployment
- IAM role must be created externally and passed via `role_arn` variable 
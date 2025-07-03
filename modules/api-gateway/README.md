# API Gateway Module

This Terraform module creates an AWS API Gateway REST API with Lambda integration for FastAPI applications.

## Features

- Creates a REST API Gateway with proxy integration
- Integrates with Lambda functions using AWS_PROXY integration
- Supports both root proxy and path proxy resources
- Configurable authorization (NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS)
- Optional CloudWatch logging with configurable retention
- Automatic deployment and stage creation
- Lambda permissions for API Gateway invocation

## Usage

### Basic Usage

```hcl
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name              = "my-fastapi-gateway"
  api_description       = "API Gateway for FastAPI Lambda function"
  lambda_invoke_arn     = module.lambda.lambda_invoke_arn
  lambda_function_name  = module.lambda.lambda_function_name
  stage_name           = "prod"
  environment          = "production"
  client               = "myclient"
  controlled_by        = "terraform"
}
```

### Advanced Usage with Custom Configuration

```hcl
module "api_gateway" {
  source = "../../modules/api-gateway"

  api_name              = "my-fastapi-gateway"
  api_description       = "API Gateway for FastAPI Lambda function"
  endpoint_type         = "REGIONAL"
  proxy_path_part       = "api"
  lambda_invoke_arn     = module.lambda.lambda_invoke_arn
  lambda_function_name  = module.lambda.lambda_function_name
  stage_name           = "staging"
  authorization_type    = "AWS_IAM"
  enable_logging        = true
  log_retention_days    = 30
  environment          = "staging"
  client               = "myclient"
  controlled_by        = "terraform"
  
  tags = {
    Project     = "FastAPI-Project"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Whether to create the API Gateway resources | `bool` | `true` | no |
| api_name | Name of the API Gateway REST API | `string` | n/a | yes |
| api_description | Description of the API Gateway REST API | `string` | `"API Gateway for Lambda integration"` | no |
| endpoint_type | Type of API Gateway endpoint | `string` | `"REGIONAL"` | no |
| proxy_path_part | Path part for the proxy resource | `string` | `"api"` | no |
| lambda_invoke_arn | Invoke ARN of the Lambda function | `string` | n/a | yes |
| lambda_function_name | Name of the Lambda function | `string` | n/a | yes |
| stage_name | Name of the API Gateway stage | `string` | `"prod"` | no |
| authorization_type | Type of authorization for API Gateway methods | `string` | `"NONE"` | no |
| authorizer_id | ID of the API Gateway authorizer (if using CUSTOM authorization) | `string` | `null` | no |
| enable_logging | Whether to enable CloudWatch logging for API Gateway | `bool` | `true` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `7` | no |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| controlled_by | Entity controlling this resource | `string` | `"terraform"` | no |
| client | Client or project name | `string` | `"default"` | no |
| tags | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| api_gateway_id | ID of the API Gateway REST API |
| api_gateway_arn | ARN of the API Gateway REST API |
| api_gateway_execution_arn | Execution ARN of the API Gateway REST API |
| api_gateway_root_resource_id | Root resource ID of the API Gateway REST API |
| api_gateway_invoke_url | Invoke URL of the API Gateway stage |
| api_gateway_stage_arn | ARN of the API Gateway stage |
| api_gateway_stage_name | Name of the API Gateway stage |
| api_gateway_deployment_id | ID of the API Gateway deployment |
| cloudwatch_log_group_name | Name of the CloudWatch log group for API Gateway |
| cloudwatch_log_group_arn | ARN of the CloudWatch log group for API Gateway |
| cloudwatch_role_arn | ARN of the IAM role for CloudWatch logging |

## Architecture

This module creates the following resources:

1. **API Gateway REST API** - The main API Gateway resource
2. **API Gateway Resources** - Proxy resources for routing requests
3. **API Gateway Methods** - HTTP methods (ANY) for handling requests
4. **Lambda Integrations** - AWS_PROXY integrations with Lambda
5. **Lambda Permissions** - Allows API Gateway to invoke Lambda
6. **API Gateway Deployment** - Deploys the API to a stage
7. **API Gateway Stage** - The stage where the API is deployed
8. **CloudWatch Log Group** - For API Gateway logging (optional)
9. **IAM Role and Policy** - For CloudWatch logging permissions (optional)

## URL Structure

The API Gateway creates the following URL structure:

- Base URL: `https://{api-id}.execute-api.{region}.amazonaws.com/{stage}`
- API Endpoint: `https://{api-id}.execute-api.{region}.amazonaws.com/{stage}/api`
- Proxy Endpoint: `https://{api-id}.execute-api.{region}.amazonaws.com/{stage}/api/{proxy+}`

## Integration with FastAPI

This module is designed to work with FastAPI applications deployed as Lambda functions using Mangum. The proxy integration allows all HTTP methods and paths to be routed to your FastAPI application.

### Example FastAPI Lambda Handler

```python
from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

@app.get("/items/{item_id}")
async def read_item(item_id: int):
    return {"item_id": item_id}

# Lambda handler
handler = Mangum(app)
```

## Security Considerations

- Use appropriate authorization types based on your security requirements
- Consider using AWS_IAM authorization for internal APIs
- Enable CloudWatch logging for monitoring and debugging
- Use HTTPS endpoints (enabled by default)
- Consider using WAF for additional security

## Cost Optimization

- Use REGIONAL endpoints unless you need EDGE optimization
- Configure appropriate log retention periods
- Consider using API Gateway caching for frequently accessed endpoints
- Monitor API Gateway usage and set up billing alerts

## Troubleshooting

### Common Issues

1. **Lambda Integration Errors**: Ensure the Lambda function name and ARN are correct
2. **Permission Denied**: Check that Lambda permissions are properly configured
3. **CORS Issues**: Configure CORS settings in your FastAPI application
4. **Timeout Issues**: Adjust Lambda timeout and API Gateway timeout settings

### Debugging

- Check CloudWatch logs for both API Gateway and Lambda
- Use AWS X-Ray for tracing requests
- Monitor API Gateway metrics in CloudWatch
- Test endpoints using the AWS Console or CLI 
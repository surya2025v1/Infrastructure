# API Gateway Common Configuration

This directory contains the Terraform configuration for deploying a FastAPI application as a Lambda function with API Gateway integration.

## Architecture

This configuration creates:
1. **Lambda Function** - Runs your FastAPI application using Mangum
2. **API Gateway** - Provides HTTP endpoints for your Lambda function
3. **CloudWatch Logging** - Logs API Gateway and Lambda activity
4. **Database Integration** - Connects to MySQL RDS via AWS Secrets Manager

## Prerequisites

1. **AWS CLI configured** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **S3 bucket** for Terraform state (already configured)
4. **DynamoDB table** for state locking (already configured)
5. **AWS Secrets Manager secret** with database credentials
6. **S3 bucket** with your Lambda deployment package

## Quick Start

### 1. Update Configuration

Edit `terraform.tfvars` to match your environment:

```hcl
# Update these values
aws_region = "us-east-2"
environment = "dev"
client      = "your-client-name"

# Update S3 bucket and key for your Lambda package
s3_bucket = "your-lambda-deployment-bucket"
s3_key    = "lambda-packages/your-app.zip"

# Update API Gateway name
api_gateway_name = "your-api-gateway-name"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

### 5. Get API Endpoint

After deployment, get your API endpoint:

```bash
terraform output api_endpoint
```

## Configuration Details

### Lambda Function

The Lambda function is configured with:
- **Runtime**: Python 3.11
- **Handler**: `main.handler` (for Mangum integration)
- **Memory**: 512 MB (configurable)
- **Timeout**: 30 seconds (configurable)
- **Environment Variables**: 
  - `DB_CREDENTIALS_SECRET_ARN`: ARN of Secrets Manager secret
  - Custom variables from `environment_variables`

### API Gateway

The API Gateway is configured with:
- **Type**: REST API
- **Endpoint**: Regional
- **Integration**: Lambda proxy integration
- **Stage**: `prod` (configurable)
- **Authorization**: None (configurable)
- **Logging**: CloudWatch (enabled by default)

### URL Structure

Your API will be available at:
- **Base URL**: `https://{api-id}.execute-api.{region}.amazonaws.com/prod/api`
- **Documentation**: `https://{api-id}.execute-api.{region}.amazonaws.com/prod/api/docs`
- **ReDoc**: `https://{api-id}.execute-api.{region}.amazonaws.com/prod/api/redoc`

## FastAPI Application Requirements

Your FastAPI application must:

1. **Use Mangum** for Lambda integration:
```python
from fastapi import FastAPI
from mangum import Mangum

app = FastAPI()

@app.get("/")
async def root():
    return {"message": "Hello World"}

# Required for Lambda
handler = Mangum(app)
```

2. **Include dependencies** in your deployment package:
```
fastapi
mangum
pymysql
boto3
```

3. **Handle database connections** using AWS Secrets Manager:
```python
import boto3
import json
import pymysql

def get_db_connection():
    secret_name = os.environ['DB_CREDENTIALS_SECRET_ARN']
    client = boto3.client('secretsmanager')
    
    response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(response['SecretString'])
    
    return pymysql.connect(
        host=secret['host'],
        port=int(secret['port']),
        user=secret['username'],
        password=secret['password'],
        database=secret['dbname']
    )
```

## Deployment Workflow

### 1. Build Lambda Package

```bash
# Create deployment directory
mkdir -p temp_package

# Install dependencies
pip install -r requirements.txt -t temp_package/

# Copy your application code
cp main.py temp_package/
cp -r your_app_directory/* temp_package/

# Create zip file
cd temp_package
zip -r ../fastapi-app.zip .
cd ..
```

### 2. Upload to S3

```bash
aws s3 cp fastapi-app.zip s3://your-lambda-deployment-bucket/lambda-packages/
```

### 3. Deploy Infrastructure

```bash
cd api-gateway/common
terraform apply
```

### 4. Test API

```bash
# Get the API endpoint
API_URL=$(terraform output -raw api_endpoint)

# Test the API
curl $API_URL/
curl $API_URL/docs
```

## Monitoring and Logging

### CloudWatch Logs

- **API Gateway logs**: `/aws/apigateway/{api-name}`
- **Lambda logs**: `/aws/lambda/{function-name}`

### View Logs

```bash
# View API Gateway logs
aws logs tail /aws/apigateway/fastapi-gateway-common --follow

# View Lambda logs
aws logs tail /aws/lambda/fastapi-lambda-common --follow
```

## Security Considerations

1. **IAM Roles**: Ensure Lambda has minimal required permissions
2. **VPC**: Consider placing Lambda in VPC for database access
3. **Authorization**: Add API Gateway authorization if needed
4. **HTTPS**: API Gateway uses HTTPS by default
5. **Secrets**: Database credentials are stored in AWS Secrets Manager

## Troubleshooting

### Common Issues

1. **Lambda Timeout**: Increase timeout in `terraform.tfvars`
2. **Memory Issues**: Increase memory size in `terraform.tfvars`
3. **Import Errors**: Ensure all dependencies are in the deployment package
4. **Database Connection**: Check Secrets Manager secret and VPC configuration

### Debug Commands

```bash
# Check Lambda function status
aws lambda get-function --function-name fastapi-lambda-common

# Test Lambda directly
aws lambda invoke --function-name fastapi-lambda-common --payload '{}' response.json

# Check API Gateway deployment
aws apigateway get-deployment --rest-api-id {api-id} --deployment-id {deployment-id}
```

## Cost Optimization

1. **Lambda**: Use appropriate memory/timeout settings
2. **API Gateway**: Monitor request counts and set up billing alerts
3. **Logs**: Configure appropriate log retention periods
4. **Caching**: Consider API Gateway caching for frequently accessed endpoints

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete the Lambda function, API Gateway, and all associated resources. 
# Lambda Deployment (Common)

This directory provides an example of how to deploy a Python 3.11 FastAPI Lambda using the reusable module in `modules/lambda`.

## Features

- **Lambda Function**: Python 3.11 runtime with configurable memory and timeout
- **Security Group**: VPC security group with outbound access (if VPC configured)
- **Conditional Deployment**: Use `create` and `delete` flags for CI/CD control
- **VPC Support**: Optional VPC configuration for private networking
- **External IAM Role**: Uses externally created IAM role for Lambda execution

## Prerequisites

1. **Create IAM Role**: You must create an IAM role with appropriate permissions for Lambda execution:
   - Basic Lambda execution permissions (`AWSLambdaBasicExecutionRole`)
   - VPC access permissions (`AWSLambdaVPCAccessExecutionRole`) if using VPC
   - Any additional permissions your Lambda function needs

2. **Update terraform.tfvars**: Replace the placeholder `role_arn` with your actual IAM role ARN

## Configuration

1. **Update terraform.tfvars**
   - Set your actual IAM role ARN in `role_arn`
   - Set your environment variables as needed
   - Configure tags and client information
   - Set VPC subnet IDs if using private networking (optional)
   - Use `create` and `delete` flags to control deployment

2. **Deploy with Terraform**
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```

## Files
- `main.tf`: Complete terraform configuration with backend and provider setup
- `variables.tf`: Input variables with sensible defaults
- `terraform.tfvars`: Configuration values (update with your actual values)
- `outputs.tf`: Lambda function outputs

## Security Features

### IAM Role (External)
- Must be created externally with appropriate permissions
- Should include basic Lambda execution permissions
- Should include VPC access permissions (if VPC configured)
- Follows least privilege principle

### Security Group (VPC)
- Outbound access to all destinations
- No inbound rules (Lambda doesn't accept direct connections)
- Automatically managed lifecycle

## Key Features
- **Conditional Creation**: Use `create = true/false` to control deployment
- **Tags**: Consistent tagging across all resources
- **VPC Support**: Optional VPC configuration for private networking
- **Environment Variables**: Configurable environment variables
- **CI/CD Ready**: Compatible with automated deployment pipelines
- **External IAM Role**: Flexible IAM role management

## Notes
- The Lambda function will only be created if `create = true`
- Source code deployment should be handled separately via CI/CD or manual upload
- Tags are automatically merged with environment, controlled_by, and client tags
- VPC configuration is optional - leave empty for public Lambda deployment
- IAM role must be created externally and passed via `role_arn` variable

# Lambda MySQL RDS Connection

This directory contains the Terraform configuration for deploying a Lambda function that connects to a MySQL RDS instance.

## How It Works

The Lambda function automatically connects to the MySQL RDS instance specified by the `rds_instance_name` variable in `terraform.tfvars`. The connection details are provided as environment variables to the Lambda function.

## Configuration

### 1. RDS Instance Name
Set the RDS instance name in `terraform.tfvars`:
```hcl
rds_instance_name = "prod1-mysql-db"
```

### 2. AWS Secrets Manager
The Lambda function uses existing AWS Secrets Manager secrets for database credentials:
- `common_db_username`: Contains the database username
- `common_db_password`: Contains the database password

These secrets must already exist in AWS Secrets Manager before deploying the Lambda function.

## Environment Variables

The following environment variables are automatically set by Terraform:

- `DB_HOST`: RDS endpoint (e.g., `prod1-mysql-db.abc123.us-east-2.rds.amazonaws.com`)
- `DB_PORT`: RDS port (usually `3306`)
- `DB_NAME`: Database name (e.g., `prod1db`)
- `DB_INSTANCE`: RDS instance identifier (e.g., `prod1-mysql-db`)
- `DB_USERNAME_SECRET_ARN`: ARN of the secret containing database username
- `DB_PASSWORD_SECRET_ARN`: ARN of the secret containing database password

## Usage in Python Code

Use the provided `database_example.py` as a reference for connecting to MySQL with AWS Secrets Manager:

```python
import os
import pymysql
import boto3

def get_secret_value(secret_arn: str) -> str:
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    return response['SecretString']

def get_db_connection():
    # Get credentials from Secrets Manager
    username = get_secret_value(os.environ.get('DB_USERNAME_SECRET_ARN'))
    password = get_secret_value(os.environ.get('DB_PASSWORD_SECRET_ARN'))
    
    connection = pymysql.connect(
        host=os.environ.get('DB_HOST'),
        port=int(os.environ.get('DB_PORT', 3306)),
        user=username,
        password=password,
        database=os.environ.get('DB_NAME'),
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
    return connection
```

## Deployment

1. **Ensure AWS Secrets Manager secrets exist**:
   - `common_db_username`: Contains the database username
   - `common_db_password`: Contains the database password

2. **Update the RDS instance name** in `terraform.tfvars` (if needed)

3. **Deploy the Lambda**:
   ```bash
   cd lambda/common
   terraform init
   terraform plan
   terraform apply
   ```

## Verification

After deployment, you can verify the connection by checking the Lambda outputs:

```bash
terraform output database_connection_info
```

This will show you the database connection details that were passed to the Lambda function.

## Security Considerations

1. **VPC Configuration**: The Lambda function is configured to run in the same VPC as the RDS instance
2. **Security Groups**: Ensure the Lambda security groups are allowed to access the RDS security group on port 3306
3. **Credentials**: Database credentials are securely stored in AWS Secrets Manager
4. **IAM Permissions**: Ensure the Lambda execution role has `secretsmanager:GetSecretValue` permission for the database secrets
5. **Encryption**: RDS instance should have encryption enabled

## Troubleshooting

### Common Issues

1. **Connection Timeout**: Check if Lambda and RDS are in the same VPC and subnets
2. **Permission Denied**: Verify security group rules allow Lambda to access RDS on port 3306
3. **Secrets Manager Access**: Ensure Lambda execution role has `secretsmanager:GetSecretValue` permission
4. **Wrong Credentials**: Verify the secrets `common_db_username` and `common_db_password` contain correct values
5. **RDS Not Found**: Verify the `rds_instance_name` matches the actual RDS identifier

### Debug Commands

```bash
# Check Lambda environment variables
aws lambda get-function-configuration --function-name fastapi-lambda-main

# Check RDS instance details
aws rds describe-db-instances --db-instance-identifier prod1-mysql-db

# Check Secrets Manager secrets
aws secretsmanager get-secret-value --secret-id common_db_username
aws secretsmanager get-secret-value --secret-id common_db_password

# Test Lambda function
aws lambda invoke --function-name fastapi-lambda-main --payload '{}' response.json
``` 
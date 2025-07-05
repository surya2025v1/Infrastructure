# S3 API Storage Deployment (Common)

This directory provides an example of how to deploy a private S3 bucket for storing Python API zip files using the reusable module in `modules/s3`.

## Features

- **Private S3 Bucket**: No public access allowed
- **Versioning Enabled**: File versioning for rollback capabilities
- **Server-Side Encryption**: AES256 encryption for data at rest
- **Cost Optimization**: Standard-IA storage class for lower costs
- **AWS Compliant Cleanup**: Files deleted after 31 days (AWS minimum requirements)
- **Conditional Deployment**: Use `create` and `delete` flags for CI/CD control
- **Comprehensive Tagging**: Consistent tagging across all resources

## Configuration

1. **Update terraform.tfvars**
   - Set your desired bucket name
   - Configure tags and client information
   - Set versioning preferences
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
- `outputs.tf`: S3 bucket outputs

## Security Features

### Public Access
- All public access is blocked
- Bucket ACL is set to private
- No public read/write permissions

### Encryption
- Server-side encryption with AES256
- Data encrypted at rest

### Versioning
- File versioning enabled by default
- Allows rollback to previous versions
- Lifecycle rules for automatic cleanup

### Lifecycle Management
- Current versions moved to STANDARD_IA after 30 days (AWS minimum requirement)
- Noncurrent versions moved to STANDARD_IA after 30 days
- Noncurrent versions deleted after 31 days (AWS requirement: expiration > transition)
- Cost optimization through Standard-IA storage class

## Key Features
- **Conditional Creation**: Use `create = true/false` to control deployment
- **Tags**: Consistent tagging across all resources
- **Versioning**: File versioning for rollback capabilities
- **Cost Optimization**: Standard-IA storage class for lower costs
- **AWS Compliant Cleanup**: Files deleted after 31 days (AWS minimum requirements)
- **CI/CD Ready**: Compatible with automated deployment pipelines
- **Private Storage**: Secure storage for Python API zip files

## Usage

After deployment, you can upload Python API zip files to the bucket:

```bash
# Upload a Python API zip file
aws s3 cp my-api.zip s3://python-api-storage-common/lambda-deployments/

# List files in the bucket
aws s3 ls s3://python-api-storage-common/lambda-deployments/
```

## Cost Optimization

The bucket is configured for maximum cost efficiency while complying with AWS requirements:
- **Standard-IA Storage**: Lower cost for infrequently accessed data
- **AWS Compliant Cleanup**: Files deleted after 31 days (AWS minimum requirement)
- **Versioning**: Only keeps versions for 31 days to reduce costs
- **AWS Compliance**: Follows AWS lifecycle rules (30-day transition minimum, expiration > transition)

## Notes
- The S3 bucket will only be created if `create = true`
- Bucket is configured for private storage only
- Versioning is enabled by default for file management
- Tags are automatically merged with environment, controlled_by, and client tags
- Use this bucket to store Python API zip files for Lambda deployment
- Standard-IA storage class provides lower costs for infrequently accessed data
- Files are deleted after 31 days for cost optimization (AWS minimum requirement) 
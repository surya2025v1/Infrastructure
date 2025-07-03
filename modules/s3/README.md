# S3 Module (Python API Storage)

This Terraform module creates a private S3 bucket for storing Python API zip files with versioning enabled and no public access.

## Features

- **Private S3 Bucket**: No public access allowed
- **Versioning Enabled**: File versioning for rollback capabilities
- **Server-Side Encryption**: AES256 encryption for data at rest
- **Cost Optimization**: Standard-IA storage class for lower costs
- **AWS Compliant Cleanup**: Files deleted after 31 days (AWS minimum requirements)
- **Conditional Creation**: Use `create` flag to control deployment
- **Comprehensive Tagging**: Consistent tagging across all resources

## Usage Example

```hcl
module "s3_api_storage" {
  source = "../../modules/s3"
  
  bucket_name = "my-python-api-storage"
  environment = "prod"
  
  enable_versioning = true
  
  tags = {
    Project     = "Python-API"
    Environment = "prod"
    Owner       = "DevOps"
    Purpose     = "API-Storage"
  }
  
  client = "myapp.com"
  create = true
  delete = false
}
```

## Required Variables
- `bucket_name`: Name of the S3 bucket for storing Python API files

## Optional Variables
- `environment`: Environment name (default: "dev")
- `tags`: Map of tags to assign to resources (default: {})
- `controlled_by`: Tag indicating what controls this resource (default: "Terraform")
- `client`: Client name for the project (default: "TBD")
- `enable_versioning`: Enable versioning for the S3 bucket (default: true)
- `create`: Flag to control S3 bucket creation (default: true)
- `delete`: Flag to control S3 bucket deletion (default: false)

## Outputs
- `bucket_name`: Name of the S3 bucket (null if not created)
- `bucket_arn`: ARN of the S3 bucket (null if not created)
- `bucket_id`: ID of the S3 bucket (null if not created)
- `bucket_region`: Region of the S3 bucket (null if not created)

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

## Notes
- The S3 bucket will only be created if `create = true`
- Bucket is configured for private storage only
- Versioning is enabled by default for file management
- Tags are automatically merged with environment, controlled_by, and client tags
- Standard-IA storage class provides lower costs for infrequently accessed data
- Files are deleted after 31 days for cost optimization (AWS minimum requirement) 
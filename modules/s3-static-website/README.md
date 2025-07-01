# S3 Static Website Module

This Terraform module creates an S3 bucket configured for static website hosting with optional CloudFront distribution.

## Features

- S3 bucket with static website hosting enabled
- Public read access for website files
- Optional CloudFront distribution for global content delivery
- Server-side encryption enabled
- Optional versioning
- Custom error page support
- Proper bucket policies and ACLs

## Usage

```hcl
module "s3_static_website" {
  source = "../../modules/s3-static-website"

  bucket_name = "my-website-bucket"
  environment = "prod"
  
  controlled_by = "Terraform"
  client = "MyClient"
  
  enable_cloudfront = true
  cloudfront_price_class = "PriceClass_100"
  cloudfront_aliases = ["example.com", "www.example.com"]
  
  tags = {
    Project     = "MyWebsite"
    Environment = "prod"
    Owner       = "DevOps"
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
| bucket_name | Name of the S3 bucket for static website hosting | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| controlled_by | Tag indicating what controls this resource | `string` | `"Terraform"` | no |
| client | Client name for the project | `string` | `"TBD"` | no |
| enable_versioning | Enable versioning for the S3 bucket | `bool` | `false` | no |
| enable_cloudfront | Enable CloudFront distribution for the website | `bool` | `false` | no |
| cloudfront_price_class | CloudFront price class | `string` | `"PriceClass_100"` | no |
| cloudfront_aliases | List of domain names for CloudFront distribution | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the S3 bucket |
| bucket_arn | The ARN of the S3 bucket |
| bucket_domain_name | The bucket domain name |
| website_endpoint | The website endpoint URL |
| website_domain | The domain of the website endpoint |
| cloudfront_distribution_id | The ID of the CloudFront distribution |
| cloudfront_domain_name | The domain name of the CloudFront distribution |
| cloudfront_distribution_arn | The ARN of the CloudFront distribution |

## Examples

### Basic S3 Static Website

```hcl
module "basic_website" {
  source = "../../modules/s3-static-website"

  bucket_name = "my-basic-website"
  environment = "dev"
}
```

### S3 Static Website with CloudFront

```hcl
module "website_with_cloudfront" {
  source = "../../modules/s3-static-website"

  bucket_name = "my-website-with-cdn"
  environment = "prod"
  
  enable_cloudfront = true
  cloudfront_price_class = "PriceClass_200"
  cloudfront_aliases = ["example.com"]
  
  tags = {
    Project = "Website"
    Environment = "prod"
  }
}
```

## Notes

- The bucket will be publicly accessible for website hosting
- Server-side encryption is enabled by default
- CloudFront distribution is optional but recommended for production
- Static website files (index.html, error.html) should be uploaded separately via a different pipeline
- The bucket is configured to serve index.html as both the index and error document 
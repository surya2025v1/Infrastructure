# Terraform S3 Static Website Infrastructure

This repository contains a modular Terraform infrastructure for creating and managing multiple S3 static websites with automated CI/CD pipelines.

## 🏗️ Architecture Overview

The project follows a modular approach with the following structure:

```
Infrastructure/
├── modules/
│   └── s3-static-website/          # Reusable S3 module
├── buckets/
│   ├── website-1/                  # Individual bucket configuration
│   └── website-2/                  # Individual bucket configuration
├── .github/workflows/
│   ├── terraform-parent.yml        # Parent pipeline
│   └── buckets/*/workflows/        # Child pipelines
└── README.md
```

## 🚀 Features

- **Modular Design**: Reusable S3 static website module
- **Multi-Bucket Support**: Easy creation of multiple websites
- **Automated CI/CD**: GitHub Actions with parent-child pipeline pattern
- **Smart Change Detection**: Only affected buckets are processed
- **CloudFront Integration**: Optional CDN for global content delivery
- **Security Best Practices**: Proper bucket policies and encryption
- **Versioning Support**: Optional S3 versioning for data protection

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- GitHub repository with Actions enabled
- AWS credentials configured as GitHub secrets

## 🔧 Setup

### 1. AWS Credentials

Configure the following GitHub secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### 2. GitHub Environments

Create a `production` environment in your GitHub repository settings for the Terraform workflows.

### 3. Repository Structure

The repository is already structured with:
- Reusable S3 module in `modules/s3-static-website/`
- Example bucket configurations in `buckets/website-1/` and `buckets/website-2/`
- CI/CD workflows in `.github/workflows/`

## 🏃‍♂️ Usage

### Creating a New Bucket

1. **Create a new bucket directory**:
   ```bash
   mkdir -p buckets/website-3
   ```

2. **Copy the template files**:
   ```bash
   cp buckets/website-1/main.tf buckets/website-3/
   cp buckets/website-1/variables.tf buckets/website-3/
   ```

3. **Create terraform.tfvars**:
   ```hcl
   aws_region = "us-east-1"
   bucket_name = "website-3-static-site"
   environment = "dev"
   
   create_error_page = false
   enable_versioning = false
   enable_cloudfront = false
   
   tags = {
     Project     = "StaticWebsites"
     Environment = "dev"
     Owner       = "DevOps"
     Purpose     = "Website-3"
   }
   ```

4. **Create index.html**:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Website 3</title>
   </head>
   <body>
       <h1>Welcome to Website 3</h1>
   </body>
   </html>
   ```

5. **Create the workflow file**:
   ```bash
   mkdir -p buckets/website-3/.github/workflows/
   cp buckets/website-1/.github/workflows/terraform-website-1.yml buckets/website-3/.github/workflows/terraform-website-3.yml
   ```

### Manual Deployment

You can manually trigger deployments using GitHub Actions:

1. Go to Actions tab in your repository
2. Select the appropriate workflow (e.g., "Terraform Website-1")
3. Click "Run workflow"
4. Choose the action (plan/apply/destroy)

### Automated Deployment

The parent pipeline automatically detects changes and triggers the appropriate child pipelines:

- **File Changes**: When you modify files in a bucket directory
- **Module Changes**: When you modify the S3 module (affects all buckets)
- **Pull Requests**: Automatic plan generation for review

## 🔄 CI/CD Pipeline Flow

### Parent Pipeline (`terraform-parent.yml`)

1. **Change Detection**: Monitors changes in `buckets/` and `modules/` directories
2. **Bucket Discovery**: Automatically finds all bucket directories
3. **Smart Triggering**: Only triggers pipelines for affected buckets
4. **Summary**: Provides deployment summary

### Child Pipelines (`terraform-website-*.yml`)

1. **Terraform Setup**: Initializes and validates Terraform
2. **Planning**: Generates execution plan
3. **Application**: Applies changes to AWS infrastructure
4. **Output**: Provides resource information and URLs

## 📊 Module Configuration

### S3 Static Website Module

The module supports the following features:

| Feature | Description | Default |
|---------|-------------|---------|
| Static Website Hosting | Enables S3 static website hosting | ✅ |
| Public Access | Configures bucket for public read access | ✅ |
| Server-Side Encryption | AES256 encryption enabled | ✅ |
| Versioning | Optional S3 versioning | ❌ |
| CloudFront | Optional CDN distribution | ❌ |
| Error Pages | Custom error page support | ❌ |

### Configuration Options

```hcl
module "s3_static_website" {
  source = "../../modules/s3-static-website"

  bucket_name = "my-website"
  environment = "prod"
  
  # Optional features
  enable_versioning = true
  enable_cloudfront = true
  create_error_page = true
  
  # CloudFront configuration
  cloudfront_price_class = "PriceClass_200"
  cloudfront_aliases = ["example.com"]
  
  # Tags
  tags = {
    Project = "MyWebsite"
    Environment = "prod"
  }
}
```

## 🔒 Security

- **Bucket Policies**: Properly configured for public read access
- **Encryption**: Server-side encryption enabled by default
- **Access Control**: Public access blocks configured appropriately
- **Versioning**: Optional for data protection

## 📈 Monitoring

### Terraform Outputs

Each deployment provides the following outputs:
- `bucket_id`: S3 bucket name
- `website_endpoint`: Website URL
- `cloudfront_domain_name`: CloudFront distribution URL (if enabled)

### GitHub Actions Summary

The workflows provide detailed summaries including:
- Changed buckets
- Terraform plan results
- Resource URLs
- Deployment status

## 🛠️ Troubleshooting

### Common Issues

1. **Bucket Name Conflicts**: Ensure unique bucket names across all configurations
2. **AWS Credentials**: Verify GitHub secrets are properly configured
3. **Terraform State**: Each bucket maintains its own state file
4. **Permissions**: Ensure AWS credentials have necessary S3 and CloudFront permissions

### Debugging

1. **Check Workflow Logs**: Review GitHub Actions logs for detailed error messages
2. **Terraform Plan**: Review the plan output before applying
3. **AWS Console**: Verify resources in AWS S3 and CloudFront consoles

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Actions logs
3. Create an issue in the repository

---

**Note**: This infrastructure is designed for development and production use. Always review security configurations before deploying to production environments. 
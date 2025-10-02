# Private ECR Repository Configuration for Temple Management System
# This file controls private ECR repository creation via GitHub Actions

# =============================================================================
# REPOSITORY CREATION CONTROL
# =============================================================================
create = true   # Set to false to prevent repository creation
delete = false  # Set to true to destroy repositories (use with caution!)

# =============================================================================
# REPOSITORY CONFIGURATION
# =============================================================================

# Private ECR Repository for Lambda Functions
repository_name = "user-api-v2"                    # Lambda function repository name
service_name    = "Temple User API"                # Service description
environment     = "prod"                           # Environment

# Common Tags
common_tags = {
  Project     = "Temple Management"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Environment = "prod"
  Purpose     = "Lambda Function Deployment"
}

# Image Scanning and Settings
scan_on_push = true
image_tag_mutability = "MUTABLE"
encryption_type = "AES256"

# Image Retention Settings
max_images = 10                      # Keep only latest 10 images
untagged_image_retention_days = 1    # Delete untagged images after 1 day
lifecycle_policy_priority_tag_prefix = "v"  # Priority for v1.0.0, v2.0.0 etc.

# =============================================================================
# NOTES
# =============================================================================
# 
# This configuration will create:
# - Private ECR repository: 103056765659.dkr.ecr.us-east-1.amazonaws.com/user-api-v2
# - Automatic lifecycle policies for image cleanup
# - Proper IAM permissions for GitHub Actions and Lambda
# 
# To modify repository:
# - Edit repository name, retention settings, tags
# - Commit changes to trigger GitHub Actions
# - Set create=true to deploy changes
# - Set delete=true to destroy repository (⚠️ USE WITH CAUTION!)
# 
# Example usage in GitHub Actions:
# - Push to master: Creates/updates repository
# - Manual dispatch: Available in GitHub Actions tab
# - Path-based triggers: Monitors ecr-repositories/ and modules/ecr/
#
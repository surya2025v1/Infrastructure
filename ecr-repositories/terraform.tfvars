# ECR Repositories Configuration for Temple Management System
# This file controls which repositories are created via GitHub Actions

# =============================================================================
# REPOSITORY CREATION CONTROL
# =============================================================================
create = true   # Set to false to prevent repository creation
delete = false  # Set to true to destroy repositories (use with caution!)

# =============================================================================
# REPOSITORY CONFIGURATIONS
# =============================================================================

# 1. PUBLIC ECR REPOSITORY (AWS Public ECR)
# For sharing client code and public artifacts
ecr_registry_url = "public.ecr.aws/x7o9n0b1"  # Your public ECR registry
repository_name  = "clients-code"               # Repository name

service_name = "Temple Management Client Tools"
environment  = "prod"

# Common Tags
common_tags = {
  Project     = "Temple Management"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
  Environment = "prod"
  Purpose     = "Client Tools"
  Visibility  = "public"
}

# Image Scanning and Settings
scan_on_push = true
image_tag_mutability = "MUTABLE"

# Image Retention Settings
max_images = 10                      # Keep only latest 10 images
untagged_image_retention_days = 1    # Delete untagged images after 1 day
lifecycle_policy_priority_tag_prefix = "v"  # Priority for v1.0.0, v2.0.0 etc.

# =============================================================================
# NOTES
# =============================================================================
# 
# This configuration will create:
# 1. Public ECR repository: public.ecr.aws/x7o9n0b1/clients-code
# 2. Private ECR repositories for Lambda functions with automatic cleanup
# 
# To modify repositories:
# - Edit repository names, registry URLs, or retention settings
# - Commit changes to trigger GitHub Actions
# - Set create=true to deploy changes
# - Set delete=true to destroy repositories (⚠️ USE WITH CAUTION!)
# 
# Example usage in GitHub Actions:
# - Push to master: Creates/updates repositories
# - Manual dispatch: Available in GitHub Actions tab
# - Path-based triggers: Monitors ecr-repositories/ and modules/ecr/
#

# S3 Module for Python API Storage
# This module creates a private S3 bucket for storing Python API zip files

# S3 Bucket for Python API storage
resource "aws_s3_bucket" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name          = var.bucket_name
    Environment   = var.environment
    Purpose       = "Python API Storage"
    "Controlled by" = var.controlled_by
    Client        = var.client
  })
}

# S3 Bucket Public Access Block - Block all public access
resource "aws_s3_bucket_public_access_block" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.api_storage[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.api_storage[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 Bucket Versioning - Enabled for file versioning
resource "aws_s3_bucket_versioning" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.api_storage[0].id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.api_storage[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "api_storage" {
  count  = var.create ? 1 : 0
  bucket = aws_s3_bucket.api_storage[0].id

  rule {
    id     = "api_storage_lifecycle"
    status = "Enabled"

    # Filter for all objects
    filter {
      prefix = ""
    }

    # Move current versions to Standard-IA after 30 days (AWS minimum requirement)
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move noncurrent versions to Standard-IA after 30 days
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    # Delete noncurrent versions after 31 days (must be greater than transition days)
    noncurrent_version_expiration {
      noncurrent_days = 31
    }
  }
} 
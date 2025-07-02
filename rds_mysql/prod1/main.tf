# Terraform configuration for Mysql RDS DB 

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-20250701"
    key            = "global/rds/global/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "TerraformStateLock"
    encrypt        = true
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "StaticWebsites"
      Environment = var.environment
      client      = var.client
      ManagedBy   = "Terraform"
      BucketName  = "website-1"
    }
  }
}

module "mysql_rds" {
  source = "../../modules/mysql-rds"

  identifier              = var.identifier
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.port
  db_subnet_group_name    = var.db_subnet_group_name
  subnet_ids              = var.subnet_ids
  vpc_id                  = var.vpc_id
  lambda_security_group_ids = var.lambda_security_group_ids
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  publicly_accessible     = var.publicly_accessible
  tags                    = var.tags
} 
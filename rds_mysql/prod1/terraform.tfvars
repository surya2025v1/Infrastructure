# AWS region for the RDS instance
aws_region = "us-east-2"
environment = "prod"
# RDS instance identifier and DB name
identifier = "prod1-mysql-db"
db_name    = "prod1db"

# Master username and password (replace with secure values)
db_username = "root"
db_password = "REPLACE_WITH_STRONG_PASSWORD"

# VPC and subnet configuration
vpc_id = "vpc-02dc931bd682cb846"
#subnet_ids = [
#  "subnet-03e2dd36ad8b2ddb2", # private-subnet-1a
#  "subnet-00123569c810e9f51", # private-subnet-1b
#  "subnet-0afe7507c9094de0c"  # private-subnet-1c
#]

#Public subnet Remove this after testing
subnet_ids = [
  "subnet-0e88b9a5f58af3830", # public-subnet-1a
  "subnet-09cdb8fbc526cbba3", # public-subnet-1b
  "subnet-0a68f373e52879c1d"  # public-subnet-1c
]
db_subnet_group_name = "rds-private-subnet-group-prod1"

# Lambda security group IDs allowed to access MySQL

# RDS instance configuration
engine_version          = "8.0"
instance_class          = "db.t3.micro"
allocated_storage       = 20
max_allocated_storage   = 100
port                    = 3306
multi_az                = false
storage_encrypted       = true
backup_retention_period = 0
skip_final_snapshot     = true
deletion_protection     = true
publicly_accessible     = true

# Additional tags
tags = {
  Project     = "MySQL-RDS"
  Environment = "prod1"
  Owner       = "DevOps"
  Purpose     = "RDS-MySQL"
  controlled_by = "Terraform"
  owner         = "web-application"
}

usage = "global" 
client="global"

# Pipeline control flags
create = true
delete = false 

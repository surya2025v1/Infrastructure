variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance."
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for the RDS instance."
  type        = string
}

variable "lambda_security_group_ids" {
  description = "List of Lambda security group IDs allowed to access MySQL."
  type        = list(string)
  default = []
}

variable "aws_region" {
  description = "AWS region for the RDS instance."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, dev)."
  type        = string
}

variable "client" {
  description = "Client name for tagging."
  type        = string
}

variable "identifier" {
  description = "The name of the RDS instance."
  type        = string
}

variable "engine_version" {
  description = "The version of MySQL to use."
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage."
  type        = number
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
}

variable "port" {
  description = "The port on which the DB accepts connections."
  type        = number
}

variable "db_subnet_group_name" {
  description = "Name for the DB subnet group."
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  type        = bool
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled."
  type        = bool
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible."
  type        = bool
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

variable "usage" {
  description = "Usage scope for the resource."
  type        = string
}

variable "create" {
  description = "Flag to control resource creation."
  type        = bool
}

variable "delete" {
  description = "Flag to control resource deletion."
  type        = bool
}

# NOTE: If 'environment' and 'client' are not used in main.tf, you can remove them from this file. 
variable "identifier" {
  description = "The name of the RDS instance."
  type        = string
}

variable "engine_version" {
  description = "The version of MySQL to use."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
}

variable "password" {
  description = "Password for the master DB user."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 3306
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
  default     = false
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled."
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "The VPC ID where the RDS and security group will be created."
  type        = string
}

variable "lambda_security_group_ids" {
  description = "List of Lambda security group IDs allowed to access MySQL."
  type        = list(string)
  default     = []
} 
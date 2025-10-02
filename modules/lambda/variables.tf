variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "Lambda function entrypoint handler (e.g., main.handler)"
  type        = string
  default     = "main.handler"
}

variable "runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.11"
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Amount of memory in MB for the Lambda function"
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function"
  type        = number
  default     = 30
}

variable "role_arn" {
  description = "IAM role ARN for Lambda execution (created externally)"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name containing the Lambda deployment package"
  type        = string
  default     = ""
}

variable "s3_key" {
  description = "S3 key (path) to the Lambda deployment package"
  type        = string
  default     = ""
}

variable "s3_object_version" {
  description = "S3 object version of the Lambda deployment package (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "controlled_by" {
  description = "Tag indicating what controls this resource"
  type        = string
  default     = "Terraform"
}

variable "client" {
  description = "Client name for the project"
  type        = string
  default     = "TBD"
}

variable "create" {
  description = "Flag to control Lambda function creation"
  type        = bool
  default     = true
}

variable "delete" {
  description = "Flag to control Lambda function deletion"
  type        = bool
  default     = false
}

variable "rds_secret_name" {
  description = "The name of the AWS Secrets Manager secret containing RDS connection details"
  type        = string
  default     = ""
}

# ECR Configuration Variables
variable "use_ecr_image" {
  description = "Flag to enable ECR image as Lambda source instead of S3/zip"
  type        = bool
  default     = false
}

variable "ecr_image_uri" {
  description = "Full ECR image URI for Lambda function (e.g., account.dkr.ecr.region.amazonaws.com/repo:tag)"
  type        = string
  default     = ""
}

variable "lambda_package_type" {
  description = "Lambda package type - either 'Zip' or 'Image'"
  type        = string
  default     = "Zip"
  validation {
    condition     = contains(["Zip", "Image"], var.lambda_package_type)
    error_message = "Lambda package type must be either 'Zip' or 'Image'."
  }
} 
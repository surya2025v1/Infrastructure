# Simple ECR Repository Module Variables

variable "repository_name" {
  description = "Name of the ECR repository to create"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the ECR repository"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Additional tags to apply to the repository"
  type        = map(string)
  default     = {}
}
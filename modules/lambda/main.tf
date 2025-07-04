# Data source for current AWS region
data "aws_region" "current" {}

# Data source to get RDS instance identifier from secret manager
data "aws_secretsmanager_secret" "rds" {
  count = var.create && var.rds_secret_name != "" ? 1 : 0
  name  = var.rds_secret_name
}

data "aws_secretsmanager_secret_version" "rds" {
  count     = var.create && var.rds_secret_name != "" ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.rds[0].id
}

locals {
  rds_secret = var.create && var.rds_secret_name != "" ? jsondecode(data.aws_secretsmanager_secret_version.rds[0].secret_string) : {}
  rds_instance_identifier = try(local.rds_secret.db_instance_identifier, local.rds_secret.dbInstanceIdentifier, local.rds_secret.db_name, local.rds_secret.database, "")
  lambda_environment_variables = merge(
    var.environment_variables,
    var.rds_secret_name != "" ? {
      RDS_HOST     = try(local.rds_secret.host, local.rds_secret.endpoint, "")
      RDS_PORT     = try(local.rds_secret.port, "3306")
      RDS_DATABASE = try(local.rds_secret.dbname, local.rds_secret.database, "")
      RDS_USERNAME = try(local.rds_secret.username, "")
      RDS_PASSWORD = try(local.rds_secret.password, "")
    } : {}
  )
}

data "aws_db_instance" "target" {
  count = var.create && local.rds_instance_identifier != "" ? 1 : 0
  db_instance_identifier = local.rds_instance_identifier
}

# Lambda Function
resource "aws_lambda_function" "this" {
  count = var.create ? 1 : 0

  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  role          = var.role_arn
  memory_size   = var.memory_size
  timeout       = var.timeout

  # Use S3 deployment if bucket is provided, otherwise use local file
  s3_bucket = var.s3_bucket != "" ? var.s3_bucket : null
  s3_key    = var.s3_key != "" ? var.s3_key : null
  s3_object_version = var.s3_object_version != "" ? var.s3_object_version : null

  # Use local file if S3 not configured
  filename = var.s3_bucket == "" ? "${path.module}/placeholder.zip" : null

  environment {
    variables = local.lambda_environment_variables
  }

  tags = merge(var.tags, {
    Environment   = var.environment
    controlled_by = var.controlled_by
    client        = var.client
  })
}

resource "null_resource" "connect_lambda_to_rds" {
  count = var.create && var.rds_secret_name != "" && local.rds_instance_identifier != "" && length(data.aws_db_instance.target) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOT
      echo "Connecting Lambda ${aws_lambda_function.this[0].function_name} to RDS ${data.aws_db_instance.target[0].id}"
      aws rds add-tags-to-resource \
        --region ${data.aws_region.current.name} \
        --resource-name ${data.aws_db_instance.target[0].id} \
        --tags Key=ConnectedLambda,Value=${aws_lambda_function.this[0].function_name}
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    lambda_arn = aws_lambda_function.this[0].arn
    rds_id     = data.aws_db_instance.target[0].id
  }

  depends_on = [aws_lambda_function.this]
} 
output "db_instance_identifier" {
  description = "The RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "db_instance_endpoint" {
  description = "The connection endpoint."
  value       = aws_db_instance.this.endpoint
}

output "db_instance_port" {
  description = "The port the database is listening on."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "The database name."
  value       = aws_db_instance.this.db_name
} 
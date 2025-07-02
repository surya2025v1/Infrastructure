# MySQL RDS Module

resource "aws_db_subnet_group" "this" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "mysql" {
  name        = "${var.identifier}-mysql-sg"
  description = "Allow MySQL access from Lambda"
  vpc_id      = var.vpc_id
  tags        = var.tags

  ingress {
    description      = "Allow MySQL from Lambda"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = var.lambda_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier              = var.identifier
  engine                  = "mysql"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  db_subnet_group_name    = aws_db_subnet_group.this.name
  multi_az                = var.multi_az
  storage_encrypted       = var.storage_encrypted
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  publicly_accessible     = var.publicly_accessible
  auto_minor_version_upgrade = true
  apply_immediately       = true
  tags                    = var.tags
} 
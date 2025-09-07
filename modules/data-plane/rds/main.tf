# Creates a KMS key for encrypting your RDS instance and Performance Insights data.
resource "aws_kms_key" "this" {
  description             = var.kms_description
  enable_key_rotation     = true # Key rotation is enabled for security.
  deletion_window_in_days = 7
}

# Tells AWS which subnets (should be private) to use for RDS.
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

# Allows you to tune Postgres settings (e.g., max_connections, work_mem).
resource "aws_db_parameter_group" "this" {
  name        = "${var.name}-pg"
  family      = "postgres${var.engine_version_major}"
  description = "Custom parameter group for ${var.name}"
  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
      # Optionally, add apply_method if you want
      apply_method = lookup(parameter.value, "apply_method", "immediate")
  }
 }
}
# Securely generates a random password for the DB master user.
resource "random_password" "master" {
  length  = 20
  special = true
}

# Securely stores the DB credentials in AWS Secrets Manager.
resource "aws_secretsmanager_secret" "db" {
  name = "${var.name}-db-credentials"
}

# Only output the secret ARN, never the actual password.
resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master.result
  })
}

#  Restricts DB access to only the EKS cluster’s security group.
resource "aws_security_group" "this" {
  name        = "${var.name}-db-sg"
  description = "Allow DB access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    security_groups = [var.eks_security_group_id]
    description = "Allow from EKS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Provisions the actual RDS Postgres instance.
resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.this.id]
  parameter_group_name    = aws_db_parameter_group.this.name
  username                = var.master_username
  password                = random_password.master.result
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.this.arn
  skip_final_snapshot     = var.skip_final_snapshot
  deletion_protection     = var.deletion_protection
  publicly_accessible     = false
  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  maintenance_window      = var.maintenance_window
  performance_insights_enabled = var.performance_insights_enabled
  #performance_insights_kms_key_id = aws_kms_key.this.arn
  tags                    = var.tags
}

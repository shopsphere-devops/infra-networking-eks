output "db_instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_instance_arn" {
  value = aws_db_instance.this.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

output "security_group_id" {
  value = aws_security_group.this.id
}

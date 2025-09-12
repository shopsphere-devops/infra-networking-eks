output "service_account_name" {
  value = var.service_account_name
}

output "namespace" {
  value = var.namespace
}

output "eso_irsa_role_arn" {
  value = aws_iam_role.eso_irsa.arn
}

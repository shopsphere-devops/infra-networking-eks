output "alb_controller_policy_arn" {
  value = aws_iam_policy.alb_controller.arn
}

output "alb_irsa_role_arn" {
  value = module.alb_irsa_role.iam_role_arn
}

output "cluster_ca_certificate" {
  value = var.cluster_ca_certificate
}

output "oidc_provider_arn" {
  value = var.oidc_provider_arn
}

output "dns_name" {
  value = aws_lb.this.dns_name
}

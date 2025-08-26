output "alb_controller_policy_arn" {
  value = aws_iam_policy.alb_controller.arn
}

output "alb_irsa_role_arn" {
  value = module.alb_irsa_role.iam_role_arn
}


# Outputs the IAM role ARN, which you’ll reference when configuring the Fluent Bit Kubernetes Service Account (via eks.amazonaws.com/role-arn annotation).
#output "fluentbit_irsa_role_arn" { value = module.fluentbit_irsa.iam_role_arn }

output "iam_role_arn" {
  description  = "The ARN of the IAM role for Fluent Bit "
  value        =  module.fluentbit_irsa.iam_role_arn
}

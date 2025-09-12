# Defines local variables for the Fluent Bit Kubernetes Service Account name and namespace, making the code more readable and maintainable.
locals {
fluentbit_sa_name = var.service_account
fluentbit_sa_namespace = var.namespace
}

# Creates an IAM policy granting Fluent Bit permissions to interact with CloudWatch Logs.
resource "aws_iam_policy" "fluentbit_cwlogs" {
name = "${var.name_prefix}-fluentbit-cwlogs"
description = "Fluent Bit permissions for CloudWatch Logs"
policy = jsonencode({
Version = "2012-10-17"
Statement = [
{
Action = [
"logs:CreateLogGroup",
"logs:CreateLogStream",
"logs:DescribeLogStreams",
"logs:PutLogEvents",
"logs:PutRetentionPolicy"
    ]
Effect = "Allow"
Resource = "*"
    }
   ]
 })
}

# Uses the terraform-aws-modules/iam/aws module to create an IAM role for the Fluent Bit service account, with the CloudWatch Logs policy attached.
module "fluentbit_irsa" {
source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
version = "5.39.1"
role_name = "${var.name_prefix}-fluentbit-irsa"
#attach_custom_policies = true
#custom_policies = { cwlogs = aws_iam_policy.fluentbit_cwlogs.arn }
role_policy_arns    = {
    cwlogs = aws_iam_policy.fluentbit_cwlogs.arn
}
oidc_providers = {
    ex = {
        provider_arn = var.oidc_provider_arn,
        namespace_service_accounts = ["${local.fluentbit_sa_namespace}:${local.fluentbit_sa_name}"]
      }
    }
    tags = var.tags
}

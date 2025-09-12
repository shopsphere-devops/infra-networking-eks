# Defines local variables for the OpenTelemetry Collector’s Kubernetes Service Account name and namespace. This makes your code easier to read and maintain.
locals {
    otel_sa_name = var.otel_service_account_name
    otel_sa_namespace = var.namespace
}

# Creates an IAM policy that allows the OpenTelemetry Collector to interact with AWS X-Ray.
resource "aws_iam_policy" "otel_xray" {
name = "${var.name_prefix}-otel-xray"
description = "OTel Collector permissions for AWS X-Ray"
policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Effect = "Allow",
            Action = [
              "xray:PutTraceSegments",  # Send trace and telemetry data to X-Ray.
              "xray:PutTelemetryRecords", # Send trace and telemetry data to X-Ray.
              "xray:GetSamplingRules",  # Retrieve sampling rules/statistics for distributed tracing.
              "xray:GetSamplingTargets",  # Retrieve sampling rules/statistics for distributed tracing.
              "xray:GetSamplingStatisticSummaries"  # Retrieve sampling rules/statistics for distributed tracing.
            ],
            Resource = "*"
        }
      ]
   })
}

# Creates an IAM role for the OpenTelemetry Collector’s service account using IRSA (IAM Roles for Service Accounts).
module "otel_irsa" {
source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
version = "5.39.1"
role_name = "${var.name_prefix}-otel-irsa"
#attach_custom_policies = true
#custom_policies = { xray = aws_iam_policy.otel_xray.arn }
role_policy_arns    = {
    xray = aws_iam_policy.otel_xray.arn
}
oidc_providers = {
    ex = {
        provider_arn = var.oidc_provider_arn,
        namespace_service_accounts = ["${local.otel_sa_namespace}:${local.otel_sa_name}"]
        }
    }
    tags = var.tags
}

# Outputs the IAM role ARN, which you’ll use to annotate the OpenTelemetry Collector’s Kubernetes Service Account.
output "otel_irsa_role_arn" { value = module.otel_irsa.iam_role_arn }

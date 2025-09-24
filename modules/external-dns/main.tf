terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Create IAM policy for ExternalDNS that allows changes only on the specific hosted zone
resource "aws_iam_policy" "externaldns_policy" {
  name        = "${var.cluster_name}-externaldns-policy-${var.env}"
  description = "Route53 permissions for ExternalDNS for zone ${var.route53_zone_name}"
  policy      = templatefile("${path.module}/iam_policy.json", { zone_id = var.route53_zone_id })
}

# Use the same role-for-service-account module pattern as your alb_irsa role
module "externaldns_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name_prefix = "${var.cluster_name}-externaldns"
  role_policy_arns = {
    externaldns = aws_iam_policy.externaldns_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = {
    Environment = var.env
    Project     = var.project
  }
}

# Install ExternalDNS with Helm
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "external-dns"
  version          = var.externaldns_chart_version
  namespace        = "external-dns"
  create_namespace = true

  # Use Helm set blocks to configure the chart. We let Helm create the SA but annotate it with the IRSA role ARN:
  set =[
    {
    name  = "provider"
    value = "aws"
  },

    {
    name  = "aws.region"
    value = var.region
  },

  # Limit ExternalDNS to manage only your hosted zone (security best practice)
    {
    name  = "extraArgs[0]"
    value = "--domain-filter=${var.route53_zone_name}"
  },

  # Use TXT ownership method or outright CNAME; TXT is often recommended.
    {
    name  = "txtOwnerId"
    value = var.cluster_name
  },

  # Let Helm create serviceaccount and then annotate it with the IRSA role arn
    {
    name  = "serviceAccount.create"
    value = "true"
  },

    {
    name  = "serviceAccount.name"
    value = "external-dns"
  },

    {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.externaldns_irsa_role.iam_role_arn
  },

  # Optional: tune log level etc
    {
    name  = "rbac.create"
    value = "true"
  }
 ]
}

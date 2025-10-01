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

  role_name = "dev-externaldns-irsa"
#  role_policy_arns = {
#    externaldns = aws_iam_policy.externaldns_policy.arn
#  }

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

resource "aws_iam_policy" "externaldns_assume_mgmt" {
  name = "${var.cluster_name}-externaldns-assume-mgmt"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::435159110051:role/Route53RecordManagerForDev"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "externaldns_assume_mgmt_attach" {
  role       = module.externaldns_irsa_role.iam_role_name
  policy_arn = aws_iam_policy.externaldns_assume_mgmt.arn
}


# Install ExternalDNS with Helm
resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  version          = var.externaldns_chart_version
  namespace        = "external-dns"
  create_namespace = true


  # Use Helm set blocks to configure the chart. We let Helm create the SA but annotate it with the IRSA role ARN:
set = [
  {
    name  = "provider"
    value = "aws"
  },
  {
    name  = "aws.region"
    value = var.region
  },
  {
    name  = "extraArgs[0]"
    value = "--domain-filter=${var.route53_zone_name}"
  },
  {
    name  = "extraArgs[1]"
    value = "--aws-assume-role=arn:aws:iam::435159110051:role/Route53RecordManagerForDev"
  },
  {
    name  = "txtOwnerId"
    value = var.cluster_name
  },
  {
    name  = "serviceAccount.create"
    value = "true"
  },
  {
    name  = "serviceAccount.name"
    value = "external-dns"
  },
    
  { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" 
    value = module.externaldns_irsa_role.iam_role_arn 
  },

  {
    name  = "rbac.create"
    value = "true"
  }
 ]
}

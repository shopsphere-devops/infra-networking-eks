############################################################
# IAM Policy for AWS Load Balancer Controller
############################################################

# This block creates an IAM policy document (in JSON) that allows the AWS Load Balancer Controller to perform a wide range of actions on AWS resources 
# (like ELB, ACM, WAF, Shield, IAM, etc.).
# The controller needs these permissions to create, modify, and delete AWS load balancers and related resources on behalf of your Kubernetes cluster.
data "aws_iam_policy_document" "alb_controller" {
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetRulePriorities",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebAcl",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "cognito-idp:DescribeUserPoolClient",
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "waf-regional:GetWebACL",
      "waf-regional:GetWebACLForResource",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections"
    ]
    resources = ["*"]
  }
}

# This creates an actual IAM policy in AWS using the document above.
# The policy will be attached to a role that the controller will use.
resource "aws_iam_policy" "alb_controller" {
  name        = "${var.cluster_name}-alb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = data.aws_iam_policy_document.alb_controller.json
}

############################################################
# IAM Role for ALB Controller (via IRSA)
############################################################

# This uses a Terraform module to create an IAM Role for Service Accounts (IRSA) for EKS.
module "alb_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

# role_name_prefix: Prefix for the IAM role name.
  role_name_prefix = "${var.cluster_name}-alb"
# attach_policy_arns: Attaches the policy created above.  
  role_policy_arns = {
    alb_controller = aws_iam_policy.alb_controller.arn
  }
  

# Connects the IAM role to the EKS cluster’s OIDC provider.
# Restricts the role to be assumable only by the aws-load-balancer-controller service account in the kube-system namespace.
# This is the recommended way (IRSA) for Kubernetes controllers to securely get AWS permissions.
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Environment = var.env
    Project     = var.project
  }
}

############################################################
# Helm Release: AWS Load Balancer Controller
############################################################

# Deploys the AWS Load Balancer Controller into your EKS cluster using Helm.
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.alb_controller_chart_version

# depends_on: Ensures the EKS cluster and IAM role are created first.
  depends_on = [
    module.alb_irsa_role
  ]

# set blocks: Passes required values to the Helm chart
# This installs the controller with the correct permissions and configuration to manage AWS load balancers for your Kubernetes services.
# clusterName, region, vpcId: Tells the controller which cluster and VPC to operate in.
  set = [
    {
    name  = "clusterName"
    value = var.cluster_name
  },

  {
    name  = "region"
    value = var.region
  },

  {
    name  = "vpcId"
    value = var.vpc_id
  },
# serviceAccount.create: Tells Helm to create a service account.
  {
    name  = "serviceAccount.create"
    value = "true"
  },
# serviceAccount.name: Names the service account.
  {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  },
# serviceAccount.annotations.eks.amazonaws.com/role-arn: Annotates the service account with the IAM role ARN created above (enables IRSA).
  {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_irsa_role.iam_role_arn
  },
 ]
}

#######################################################
#    PROVIDERS
#######################################################

# Use the AWS Provider and the AWS Profile is dev-sso
provider "aws" {
  region  = "us-east-1"
  profile = "dev-sso"
}

# The helm provider is used for managing Helm charts (like installing the AWS Load Balancer Controller). 
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# The kubernetes provider is used for managing Kubernetes resources directly (like creating a ServiceAccount).
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

#######################################################
#    DATA BLOCK
#######################################################

# Terraform Data block is used to fetch data from outside terraform (AWS). 
# We are fetching the AWS Availability Zones dynamically.
data "aws_availability_zones" "available" {}

# Fetching EKS Cluster AUth Details
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

#######################################################
#    MODULES
#######################################################

# AWS VPC Module
module "vpc" {
  name = "dev-vpc"
  source        = "../../modules/vpc"
  vpc_cidr      = "10.10.0.0/16"
  azs = data.aws_availability_zones.available.names
  public_subnets = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnets = ["10.10.10.0/24", "10.10.11.0/24"]
  tags = { Name = "shopsphere-dev-vpc" }
}

#######################################################
#    EKS CLUSTER
#######################################################

# AWS EKS Module. We are using EKS managed Node groups
module "eks" {
  source = "../../modules/eks"
  cluster_name = "shopsphere-dev-eks"
  vpc_id = module.vpc.id
  private_subnet_ids = module.vpc.private_subnets
  node_groups = {
    on_demand = {
      desired_capacity = 2
      max_capacity = 3
      min_capacity = 2
      instance_types = ["t3.medium"]
      capacity_type = "ON_DEMAND"
    }
    spot_nodes = {
      desired_capacity = 0
      max_capacity = 4
      min_capacity = 0
      instance_types = ["m5.large", "t3.large"]
      capacity_type = "SPOT"
    }
  }
}

# create IAM role for ALB (trust policy)
resource "aws_iam_role" "alb_sa_role" {
  name = "eks-alb-controller-role-dev"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }]
  })
}

# Create the policy used by ALB controller
resource "aws_iam_policy" "alb_policy" {
  name = "ALBControllerPolicy-shopsphere-dev"
  policy = file("${path.module}/../../modules/eks/policies/alb-controller-policy.json")
}

# Attach the policy to Role.
resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_sa_role.name
  policy_arn = aws_iam_policy.alb_policy.arn
}

#######################################################
#    AWS Load Balancer Controller
#######################################################

# Install AWS Load Balancer Controller via Helm (uses IRSA role)
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.4"

  set = [
    {
    name  = "clusterName"
    value = module.eks.cluster_name
  },

    {
    name  = "serviceAccount.create"
    value = "false"
  },

    {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  },

    {
    name  = "region"
    value = "us-east-1"
  },

    {
    name  = "vpcId"
    value = module.vpc.id
  }
 ]
}

# Service account with the IRSA annotation
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_sa_role.arn
    }
  }
}

#######################################################
#    AWS ECR
#######################################################

locals {
  repo_names = ["catalog", "user", "frontend"]
  common_tags = {
    Environment = "dev"    
  }
}

module "ecr_repos" {
  source   = "../../modules/ecr"
  for_each = toset(local.repo_names)

  repo_name = each.value
  tags      = local.common_tags
}


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
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

# The kubernetes provider is used for managing Kubernetes resources directly (like creating a ServiceAccount).
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

#######################################################
#    DATA BLOCK
#######################################################

# Terraform Data block is used to fetch data from outside terraform (AWS). 
# We are fetching the AWS Availability Zones dynamically.
data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

# Fetching EKS Cluster Auth Details
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

#######################################################
#    MODULES
#######################################################

# AWS VPC Module
module "vpc" {
source = "../../modules/vpc"
  env              = var.env
  cidr             = var.cidr
  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  public_subnet_tags   = var.public_subnet_tags
  private_subnet_tags  = var.private_subnet_tags
  tags                = var.tags
  cluster_name        = var.cluster_name  
}

#######################################################
#    EKS CLUSTER
#######################################################

# AWS EKS Module. We are using EKS managed Node groups
module "eks" {
  source = "../../modules/eks"
  cluster_name      = var.cluster_name
  kubernetes_version = var.kubernetes_version
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  cluster_enabled_log_types = var.cluster_enabled_log_types
  enable_irsa = var.enable_irsa
  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  cluster_addons = var.cluster_addons
  eks_managed_node_groups = var.eks_managed_node_groups
  tags = var.tags
}

#######################################################
#    APPLICATION LOAD BALANCER - HELM 
#######################################################

module "helm_alb" {
  source = "../../modules/helm-alb"

  cluster_name        = module.eks.cluster_name
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  oidc_provider_arn   = module.eks.oidc_provider_arn
  alb_controller_chart_version = var.alb_controller_chart_version
  env                 = var.env
  project             = var.project
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


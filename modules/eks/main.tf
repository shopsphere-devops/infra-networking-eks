############################################################
# Providers (assumes: provider "aws" {} is already declared)
############################################################
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.29"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13"
    }
  }
}

############################################################
# Data helpers
############################################################
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

############################################################
# EKS Cluster + Managed Node Groups
# Uses: terraform-aws-modules/eks/aws (v20+)
############################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.24"

  cluster_name                   = var.cluster_name
  cluster_version                = var.kubernetes_version
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  # VPC wiring from your vpc.tf
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  # Endpoint & access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # Logging
  cluster_enabled_log_types = var.cluster_enabled_log_types

  # IRSA must be enabled for addons/Helm service accounts
  enable_irsa = var.enable_irsa

  # Manage aws-auth ConfigMap automatically
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  # Core EKS Add-ons (AWS-managed)
  cluster_addons = var.cluster_addons

  ##########################################################
  # Managed Node Groups
  ##########################################################
  eks_managed_node_groups = var.eks_managed_node_groups

  ##########################################################
  # Tags
  ##########################################################
  tags = var.tags
}

############################################################
# Wire up Kubernetes & Helm providers AFTER cluster exists
############################################################
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

############################################################
# (Optional) Map extra roles/users into aws-auth
# module.eks supports this via aws_auth_* variables.
############################################################
# module "eks" {
#   ...
#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::123456789012:role/sre-admin"
#       username = "sre-admin"
#       groups   = ["system:masters"]
#     }
#   ]
# }

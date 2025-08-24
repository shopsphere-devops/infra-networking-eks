module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  
  name    = var.cluster_name
  kubernetes_version = "1.30"

  #bootstrap_self_managed_addons = false
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Optional
  # cluster_endpoint_public_access = true
  enable_irsa = true
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  #control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  eks_managed_node_groups = var.node_groups

  tags = { 
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" 
  }
}

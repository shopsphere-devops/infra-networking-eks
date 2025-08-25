# Uses a community-maintained module for EKS, which abstracts away much of the complexity of setting up EKS.
# Specifies the module version (~> 21.0).
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

# Sets the EKS cluster name from a variable.
# Specifies the Kubernetes version to deploy (1.31).  
  name    = var.cluster_name
  kubernetes_version = "1.31"

# Installs essential EKS addons:
# coredns: DNS for Kubernetes pods.
# eks-pod-identity-agent: Enables IAM roles for service accounts (IRSA).
# kube-proxy: Handles networking for Kubernetes.
# vpc-cni: AWS VPC networking for pods. 
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

# Enables IRSA, allowing Kubernetes service accounts to assume IAM roles for fine-grained AWS permissions.  
  enable_irsa = true

# Gives the Terraform user (the one running apply) admin access to the cluster via AWS IAM.  
  enable_cluster_creator_admin_permissions = true

# Specifies the VPC where the cluster will be created.
# Specifies the subnets for the cluster nodes (usually private subnets for security).
# (Optional) You could specify control plane subnets, but it's commented out.
  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  #control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

# Defines EKS managed node groups (the EC2 instances that run your Kubernetes workloads).
# The details (instance types, scaling, etc.) are provided via the var.node_groups variable.
  eks_managed_node_groups = var.node_groups

# Tags the resources for identification and integration with other AWS services (like load balancers).
  tags = { 
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" 
  }
}

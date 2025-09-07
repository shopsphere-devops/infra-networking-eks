#######################################################
#    Environment Details
#######################################################

env          = "dev"
region       = "us-east-1"
project      = "shopsphere"
cluster_name = "shopsphere-dev-eks"

tags = {
  Environment = "dev"
  Project     = "shopsphere"
  Terraform   = "true"
}

#######################################################
#    VPC
#######################################################

# cidr: The VPC’s IP range is 10.10.0.0/16 (65536 IPs).
cidr = "10.10.0.0/16"
# # azs: Resources will be spread across three AZs for high availability.
azs = ["us-east-1a", "us-east-1b", "us-east-1c"]

# private_subnets: Three private subnets, one per AZ.
private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
# public_subnets: Three public subnets, one per AZ.
public_subnets = ["10.10.101.0/24", "10.10.102.0/24", "10.10.103.0/24"]

# enable_nat_gateway: Creates a NAT Gateway so private subnets can access the internet.
# intentionally set to false for cost optimization.
enable_nat_gateway = false
# single_nat_gateway: Only one NAT Gateway is created (cost-saving, but less HA).
single_nat_gateway = true
# enable_dns_hostnames & enable_dns_support: Enables DNS resolution and hostnames in the VPC (required for EKS and other AWS services).
enable_dns_hostnames = true
enable_dns_support   = true

map_public_ip_on_launch = true
# Subnet Tags for Kubernetes (EKS)
# These tags are required by EKS (Kubernetes on AWS) to identify which subnets can be used for public (ELB) and internal (internal-ELB) load balancers.
# "shared": Means the subnets can be used by multiple clusters (if needed).
public_subnet_tags = {
  "kubernetes.io/role/elb"                   = "1"
  "kubernetes.io/cluster/shopsphere-dev-eks" = "shared"
}

private_subnet_tags = {
  "kubernetes.io/role/internal-elb"          = "1"
  "kubernetes.io/cluster/shopsphere-dev-eks" = "shared"
}

#######################################################
#    EKS
#######################################################


kubernetes_version                       = "1.33"
enable_cluster_creator_admin_permissions = true

cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

cluster_enabled_log_types = ["api", "audit"]

enable_irsa               = true
manage_aws_auth_configmap = true

cluster_addons = {
  coredns = {
    most_recent       = true
    resolve_conflicts = "OVERWRITE"
  }
  kube-proxy = {
    most_recent       = true
    resolve_conflicts = "OVERWRITE"
  }
  vpc-cni = {
    most_recent          = true
    resolve_conflicts    = "OVERWRITE"
    configuration_values = "{\"env\":{\"ENABLE_PREFIX_DELEGATION\":\"true\",\"WARM_PREFIX_TARGET\":\"1\"}}"
  }
  aws-ebs-csi-driver = {
    most_recent       = true
    resolve_conflicts = "OVERWRITE"
    service_account = {
      create = true
      name   = "ebs-csi-controller-sa"
      attach_policy_arns = [
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      ]
    }
  }
}

eks_managed_node_groups = {
  # commented the on_demand nodes for cost optimization
  /*on_demand = {
    name            = "on_demand"
    use_name_prefix = false
    ami_type        = "AL2_x86_64"
    capacity_type   = "ON_DEMAND"
    instance_types  = ["t3.medium"]
    min_size        = 0
    max_size        = 0
    desired_size    = 0
    #subnet_ids      = null # Will be set by module
    create_security_group      = true
    #enable_bootstrap_user_data = true
    iam_role_additional_policies = {
      ecr_readonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      cni_policy   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      worker_node  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    }
    labels = {
      lifecycle = "on-demand"
      nodepool  = "general"
    }
  }
*/
  spot_nodes = {
    name            = "spot_nodes"
    use_name_prefix = false
    ami_type        = "BOTTLEROCKET_x86_64"
    capacity_type   = "SPOT"
    instance_types  = ["t3.medium", "t3a.medium", "m5.xlarge", "t3.large", "t3a.large", "m5.large", "m5a.large"]
    min_size        = 2
    max_size        = 8
    desired_size    = 2
    #subnet_ids      = null # Will be set by module
    create_security_group = true
    #enable_bootstrap_user_data = true
    iam_role_additional_policies = {
      ecr_readonly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      cni_policy   = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      worker_node  = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    }
    labels = {
      lifecycle = "spot"
      nodepool  = "general"
    }
  }
}

#######################################################
#    RDS
#######################################################

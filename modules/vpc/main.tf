##################################################
# VPC
##################################################

# This block uses the terraform-aws-modules/vpc/aws community module to create a VPC and related networking resources.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.10"

  # The VPC will be named according to your environment variable (e.g., dev-vpc).
  name = "${var.env}-vpc"
  # The VPC’s IP range
  cidr = var.cidr

  # azs: Resources will be spread across three AZs for high availability.
  azs = var.azs
  # private_subnets: Three private subnets, one per AZ.
  private_subnets = var.private_subnets
  # public_subnets: Three public subnets, one per AZ.
  public_subnets = var.public_subnets

  map_public_ip_on_launch = var.map_public_ip_on_launch
  # enable_nat_gateway: Creates a NAT Gateway so private subnets can access the internet.
  enable_nat_gateway = var.enable_nat_gateway
  # single_nat_gateway: Only one NAT Gateway is created (cost-saving, but less HA).
  single_nat_gateway = var.single_nat_gateway
  # enable_dns_hostnames & enable_dns_support: Enables DNS resolution and hostnames in the VPC (required for EKS and other AWS services).
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Subnet Tags for Kubernetes (EKS)
  # These tags are required by EKS (Kubernetes on AWS) to identify which subnets can be used for public (ELB) and internal (internal-ELB) load balancers.
  # "shared": Means the subnets can be used by multiple clusters (if needed).
  public_subnet_tags = var.public_subnet_tags

  private_subnet_tags = var.private_subnet_tags

  # General Tags
  # Adds metadata to all resources for identification and cost allocation.
  tags = var.tags
}

##################################################
# Security group for EKS cluster communication
##################################################

# Creates a Security Group in the VPC created above.
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id
  # Egress Rule: Allows all outbound traffic to anywhere (0.0.0.0/0), all ports, all protocols.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Tags: For identification.
  tags = {
    Name        = "${var.cluster_name}-sg"
    Environment = var.env
  }
}

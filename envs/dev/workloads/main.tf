#######################################################
#    PROVIDERS
#######################################################

# Use the AWS Provider and the AWS Profile is dev-sso
provider "aws" {
  region  = "us-east-1"
  profile = "dev-sso"
}

# The kubernetes provider is used for managing Kubernetes resources directly (like creating a ServiceAccount).
provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.this.token
}

# The helm provider is used for managing Helm charts (like installing the AWS Load Balancer Controller).
provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

#######################################################
#    DATA BLOCK
#######################################################

# Terraform Data block is used to fetch data from outside terraform (AWS).
# We are fetching the AWS Availability Zones dynamically.
data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

# Fetching EKS Cluster Auth Details
data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

#######################################################
#    APPLICATION LOAD BALANCER - HELM
#######################################################

module "helm_alb" {
  source = "../../../modules/helm-alb"

  cluster_name                 = data.terraform_remote_state.infra.outputs.cluster_name
  region                       = var.region
  vpc_id                       = data.terraform_remote_state.infra.outputs.vpc_id
  cluster_ca_certificate       = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  oidc_provider_arn            = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  alb_controller_chart_version = var.alb_controller_chart_version
  env                          = var.env
  project                      = var.project
}

#######################################################
#    OBSERVABILITY
#######################################################

module "observability" {
  source = "../../../modules/observability"

  # Pass the cluster connection info to the module
  # These are needed for the helm and kubernetes providers inside the module
  cluster_endpoint          = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate    = data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  cluster_token             = data.aws_eks_cluster_auth.this.token
  alb_controller_dependency = module.helm_alb

  # Optionally, pass the namespace as a variable if you want to make it configurable
  # monitoring_namespace     = "monitoring"
}

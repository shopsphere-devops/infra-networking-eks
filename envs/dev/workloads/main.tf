#######################################################
#    PROVIDERS
#######################################################

# Use the AWS Provider and the AWS Profile is dev-sso
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "dns"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::435159110051:role/Route53RecordManagerForDev"
  }
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

data "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-server-ingress"
    namespace = "argocd"
  }
}

#######################################################
#    APPLICATION LOAD BALANCER - HELM
#######################################################

module "alb_controller" {
  source = "../../../modules/alb_controller"

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

module "fluentbit_irsa_role" {
  source            = "../../../modules/observability/iam/fluentbit-irsa"
  cluster_name      = var.cluster_name
  oidc_provider_arn = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  namespace         = "observability"
  name_prefix       = "shopsphere-dev"
  service_account   = "fluent-bit"
  # Add any other required variables for your IRSA module
}

module "observability" {
  source = "../../../modules/observability"

  namespace          = "observability"
  name_prefix        = "shopsphere-dev"
  cluster_name       = var.cluster_name
  oidc_provider_arn  = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  tags               = var.tags
  region             = var.region
  fluentbit_role_arn = module.fluentbit_irsa_role.iam_role_arn
  depends_on = [
    module.alb_controller
  ]

  # If you want to override SA names or chart versions, set vars here
}

#######################################################
#    External Secrets Operator (ESO)
#######################################################

module "eso" {
  source               = "../../../modules/eso"
  namespace            = "external-secrets"
  chart_version        = "0.9.18"
  service_account_name = "external-secrets"
  kubeconfig_path      = var.kubeconfig_path
  secretsmanager_arns  = [data.terraform_remote_state.infra.outputs.db_secret_arn]
  eks_cluster_name     = var.cluster_name

  kubernetes_provider = kubernetes
  /*
  providers = {
    kubernetes = kubernetes
  }
*/
  depends_on = [
    module.alb_controller
  ]
}

#######################################################
#    ARGO CD
#######################################################

module "argocd" {
  source        = "../../../modules/argocd"
  release_name  = var.argocd_release_name
  namespace     = var.argocd_namespace
  chart_version = var.argocd_chart_version
  argocd_values = var.argocd_values
  depends_on = [
    module.alb_controller
  ]
}

#######################################################
#    External DNS
#######################################################
module "external_dns" {
  source = "../../../modules/external-dns"

  cluster_name              = data.terraform_remote_state.infra.outputs.cluster_name
  oidc_provider_arn         = data.terraform_remote_state.infra.outputs.oidc_provider_arn
  region                    = var.region
  env                       = var.env
  project                   = var.project
  route53_zone_id           = var.route53_zone_id
  route53_zone_name         = var.route53_zone_name # set this variable in workloads/terraform.tfvars
  externaldns_chart_version = var.externaldns_chart_version
}
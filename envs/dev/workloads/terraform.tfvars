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
#    ArgoCD
#######################################################

argocd_release_name  = "argocd"
argocd_namespace     = "argocd"
argocd_chart_version = "5.51.6"

argocd_values = {
  server = {
    extraArgs = ["--insecure"]
    service   = { type = "ClusterIP" }
    metrics   = { enabled = true }
  }
  repoServer = {
    resources = {
      limits = { cpu = "500m", memory = "512Mi" }
    }
  }
  controller = {
    resources = {
      limits = { cpu = "500m", memory = "512Mi" }
    }
  }
}

#######################################################
#    External Secrets Operator (ESO)
#######################################################
kubeconfig_path = "~/.kube/config"

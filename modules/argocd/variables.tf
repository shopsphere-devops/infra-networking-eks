variable "release_name" {
  description = "Name of the Helm release"
  type        = string
  default     = "argocd"
}

variable "namespace" {
  description = "Namespace to install Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "argocd_values" {
  description = "Values for Argo CD Helm chart"
  type        = any
  default     = {
    server = {
      extraArgs = ["--insecure"]
      service = {
        type = "ClusterIP"
      }
      metrics = {
        enabled = true
      }
    }
    repoServer = {
      metrics = {
        enabled = true
      }
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
    controller = {
      metrics = {
        enabled = true
      }
      resources = {
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    }
    dex = {
      metrics = {
        enabled = true
      }
    }
    applicationSet = {
      metrics = {
        enabled = true
      }
    }
  }
}

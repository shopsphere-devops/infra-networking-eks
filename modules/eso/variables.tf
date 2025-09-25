variable "namespace" {
  description = "Namespace to deploy ESO"
  type        = string
  default     = "external-secrets"
}

variable "chart_version" {
  description = "ESO Helm chart version"
  type        = string
  default     = "0.9.18" # Check for latest version
}

variable "service_account_name" {
  description = "Service account name for ESO"
  type        = string
  default     = "external-secrets"
}

/*variable "irsa_role_arn" {
  description = "IAM Role ARN for IRSA"
  type        = string
}
*/
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eso_namespace" {
  description = "Namespace where ESO is deployed"
  type        = string
  default     = "external-secrets"
}

variable "eso_service_account_name" {
  description = "Service account name for ESO"
  type        = string
  default     = "external-secrets"
}

variable "secretsmanager_arns" {
  description = "List of Secrets Manager ARNs ESO can access"
  type        = list(string)
}

variable "kubernetes_provider" {
  description = "The Kubernetes provider to use"
  type        = any
}

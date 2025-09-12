 variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Namespace where the ServiceAccount exists"
  type        = string
}

variable "service_account" {
  description = "ServiceAccount name for Fluent Bit"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

# ALB Variables Placeholder
variable "region" {
  description = "AWS region"
  type        = string
}

variable "alb_controller_chart_version" {
  description = "Version of the AWS ALB Controller Helm chart"
  type        = string
  default     = "1.8.1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "shopsphere"
}


# ArgoCD Variables
variable "argocd_release_name" {
  description = "Argo CD Helm release name"
  type        = string
  default     = "argocd"
}

variable "argocd_namespace" {
  description = "Namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "argocd_values" {
  description = "Values for Argo CD Helm chart"
  type        = any
  default     = {}
}

#######################################################
#    External Secrets Operator (ESO)
#######################################################

/*variable "eso_irsa_role_arn" {
  description = "IRSA role ARN for ESO"
  type        = string
}
*/
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

/*variable "db_secret_arn" {
  description = "ARN of the RDS DB secret"
  type        = string
}
*/

#######################################################
#    Route53
#######################################################

variable "route53_zone_id" {
  type = string
}
variable "route53_zone_name" {
  type = string
  description = "example: hellosaanvika.com"
}
variable "externaldns_chart_version" {
  type    = string
  default = "10.6.0"
}

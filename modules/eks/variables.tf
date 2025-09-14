variable "cluster_name" { type = string }
variable "kubernetes_version" { type = string }
variable "enable_cluster_creator_admin_permissions" { type = bool }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "cluster_endpoint_public_access" { type = bool }
variable "cluster_endpoint_private_access" { type = bool }
variable "cluster_endpoint_public_access_cidrs" { type = list(string) }
variable "cluster_enabled_log_types" { type = list(string) }
variable "enable_irsa" { type = bool }
variable "manage_aws_auth_configmap" { type = bool }
variable "cluster_addons" { type = any }
variable "eks_managed_node_groups" { type = any }
variable "tags" { type = map(string) }
/*
variable "aws_auth_roles" {
  description = "List of role mappings for aws-auth configmap"
  type        = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default     = []
}
*/

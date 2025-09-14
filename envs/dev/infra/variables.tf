# VPC Variables Placeholder
variable "env" { type = string }
variable "cidr" { type = string }
variable "azs" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "public_subnets" { type = list(string) }
variable "enable_nat_gateway" { type = bool }
variable "single_nat_gateway" { type = bool }
variable "enable_dns_hostnames" { type = bool }
variable "enable_dns_support" { type = bool }
variable "public_subnet_tags" { type = map(string) }
variable "private_subnet_tags" { type = map(string) }
variable "tags" { type = map(string) }
variable "cluster_name" { type = string }

# EKS Variables Placeholder
variable "kubernetes_version" { type = string }
variable "enable_cluster_creator_admin_permissions" { type = bool }
variable "cluster_endpoint_public_access" { type = bool }
variable "cluster_endpoint_private_access" { type = bool }
variable "cluster_endpoint_public_access_cidrs" { type = list(string) }
variable "cluster_enabled_log_types" { type = list(string) }
variable "enable_irsa" { type = bool }
variable "manage_aws_auth_configmap" { type = bool }
variable "cluster_addons" { type = any }
variable "eks_managed_node_groups" { type = any }

variable "access_entries" {
  description = "Map of access entries for aws-auth"
  type        = map(any)
  default     = {}
}

# ALB Variables Placeholder
variable "region" { type = string }

variable "alb_controller_chart_version" {
  type    = string
  default = "1.8.1"
}

variable "project" {
  type    = string
  default = "shopsphere"
}

variable "map_public_ip_on_launch" {
  description = "Should be true to auto-assign public IPs in public subnets"
  type        = bool
  default     = false
}

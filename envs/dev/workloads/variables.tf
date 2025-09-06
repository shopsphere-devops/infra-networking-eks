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

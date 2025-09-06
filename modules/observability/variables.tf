variable "cluster_endpoint" {}
variable "cluster_ca_certificate" {}
variable "cluster_token" {}
variable "monitoring_namespace" { default = "monitoring" }

variable "alb_controller_dependency" {
  description = "Dummy variable to force dependency on ALB controller"
  default     = null
}

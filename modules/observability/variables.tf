variable "namespace" { type = string }
variable "name_prefix" { type = string }
variable "cluster_name" { type = string }
variable "region" { type = string }
variable "oidc_provider_arn" { type = string }

variable "tags" {
    type = map(string)
    default = {}
    }

# ServiceAccount names (chart values must match)
variable "fluentbit_service_account_name" {
    type = string
    default = "fluent-bit"
    }

variable "otel_service_account_name" {
    type = string
    default = "otel-collector"
    }

# Chart versions (pin for reproducibility)

# kube-prometheus-stack
variable "kps_chart_version" {
    type = string
    default = "66.5.0"
    }

# fluent-bit
variable "fb_chart_version" {
    type = string
    default = "0.49.0"
    }

#opentelemetry-collector
variable "otel_chart_version" {
    type = string
    default = "0.100.0"
    }

variable "fluentbit_role_arn" {
  description = "IAM Role ARN for Fluent Bit IRSA"
  type        = string
}

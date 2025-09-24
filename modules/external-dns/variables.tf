variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" { type = string }
variable "project" { type = string }

variable "route53_zone_id" {
  type = string
  description = "Hosted zone ID in management account for hellosaanvika.com"
}

variable "route53_zone_name" {
  type = string
  description = "Hosted zone name (e.g. hellosaanvika.com)"
}

variable "externaldns_chart_version" {
  type    = string
  default = "1.15.0" # latest stable as of Sept 2025
}

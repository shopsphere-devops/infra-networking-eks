 variable "zone_id" {
  description = "The Route53 Hosted Zone ID"
  type        = string
}

variable "record_name" {
  description = "The DNS record name (e.g., argocd.example.com)"
  type        = string
}

variable "record_type" {
  description = "The DNS record type (e.g., CNAME, A)"
  type        = string
  default     = "CNAME"
}

variable "record_value" {
  description = "The value for the DNS record (e.g., ALB DNS name)"
  type        = string
}

variable "ttl" {
  description = "The TTL for the DNS record"
  type        = number
  default     = 300
}

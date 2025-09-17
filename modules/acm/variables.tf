variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
}

variable "zone_id" {
  description = "The Route53 Hosted Zone ID for DNS validation"
  type        = string
}

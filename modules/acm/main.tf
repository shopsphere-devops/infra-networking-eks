terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

# Requests an SSL/TLS certificate from AWS Certificate Manager (ACM) for the domain specified in var.domain_name.
# validation_method = "DNS": Tells ACM you will prove ownership of the domain by creating a DNS record.
# lifecycle : Ensures that if you ever change the certificate, Terraform will create the new one before deleting the old one (to avoid downtime).
resource "aws_acm_certificate" "this" {
  provider          = aws
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# The ACM certificate resource outputs a set of objects called domain_validation_options. Each object contains the DNS record details you need to create for validation.
# tolist(...)[0]: Converts the set to a list and takes the first (and only) element. This is safe if you are only validating a single domain.
# local.dvo: Now holds an object with the DNS record name, type, and value needed for validation.
locals {
  dvo = tolist(aws_acm_certificate.this.domain_validation_options)[0]
}

# Creates a DNS record in your Route53 hosted zone (var.zone_id) with the name, type, and value provided by ACM.
# This record proves to ACM that you control the domain, allowing ACM to issue the certificate.
resource "aws_route53_record" "validation" {
  provider = aws.dns
  zone_id = var.zone_id
  name    = local.dvo.resource_record_name
  type    = local.dvo.resource_record_type
  records = [local.dvo.resource_record_value]
  ttl     = 60
}

# Tells ACM to check the DNS record you just created and, if it matches, to validate and issue the certificate.
# certificate_arn: References the certificate you requested.
# validation_record_fqdns: Points to the fully qualified DNS name of the validation record you created.
resource "aws_acm_certificate_validation" "this" {
  provider                = aws
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}

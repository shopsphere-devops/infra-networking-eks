resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  dvo = tolist(aws_acm_certificate.this.domain_validation_options)[0]
}

resource "aws_route53_record" "validation" {
  zone_id = var.zone_id
  name    = local.dvo.resource_record_name
  type    = local.dvo.resource_record_type
  records = [local.dvo.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}

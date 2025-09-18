resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count   = length(aws_acm_certificate.this.domain_validation_options)
  zone_id = var.zone_id
  name    = aws_acm_certificate.this.domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.this.domain_validation_options[count.index].resource_record_type
  records = [aws_acm_certificate.this.domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}
/*
  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}
*/
resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

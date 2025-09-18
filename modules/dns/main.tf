terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

resource "aws_route53_record" "this" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type
  ttl     = var.ttl
  records = [var.record_value]
}

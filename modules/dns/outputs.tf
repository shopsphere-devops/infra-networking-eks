output "fqdn" {
  description = "The FQDN of the DNS record"
  value       = aws_route53_record.this.fqdn
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_ca_certificate
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "db_secret_arn" {
  value = module.rds.db_secret_arn
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "acm_cert_arn" {
  value = module.acm.certificate_arn
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "managed_node_group_role_arns" {
  value = { for k, v in module.eks.eks_managed_node_groups : k => v.iam_role_arn }
}
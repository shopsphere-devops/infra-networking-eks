output "argocd_server_url" {
  description = "Argo CD server URL"
  value       = "https://argocd.${var.namespace}.svc.cluster.local"
}

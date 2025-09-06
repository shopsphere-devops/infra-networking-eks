output "grafana_admin_password_secret" {
  value = "observability/kube-prometheus-stack-grafana"
}
/*
output "grafana_service" {
  value = helm_release.kube_prometheus_stack.status[0].resources["Service/grafana"]
}
*/
output "grafana_service_endpoint" {
  value       = data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname
  description = "The external endpoint for Grafana"
}

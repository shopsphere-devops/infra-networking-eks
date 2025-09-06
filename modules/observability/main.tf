provider "helm" {
  kubernetes = {
    #host                   = var.cluster_endpoint
    #cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
    #token                  = var.cluster_token
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  #host                   = var.cluster_endpoint
  #cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  #token                  = var.cluster_token
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.6.0" # Use latest stable

  values = [
    file("${path.module}/values/kube-prometheus-stack-values.yaml")
  ]
  depends_on = [
    var.alb_controller_dependency,
    kubernetes_namespace.monitoring
  ]
}

data "kubernetes_service" "grafana" {
  metadata {
    name      = "kube-prometheus-stack-grafana"
    namespace = "monitoring"
  }
  depends_on = [helm_release.kube_prometheus_stack]
}

resource "helm_release" "loki" {
  name       = "loki"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "5.41.7"

  values = [
    file("${path.module}/values/loki-values.yaml")
  ]

  depends_on = [
    var.alb_controller_dependency,
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  namespace  = "monitoring"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.46.6"

  values = [
    file("${path.module}/values/fluent-bit-values.yaml")
  ]
  depends_on = [
    var.alb_controller_dependency,
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "tempo" {
  name       = "tempo"
  namespace  = "monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = "1.7.1"

  values = [
    file("${path.module}/values/tempo-values.yaml")
  ]
  depends_on = [
    var.alb_controller_dependency,
    kubernetes_namespace.monitoring
  ]
}

resource "helm_release" "otel_collector" {
  name       = "otel-collector"
  namespace  = "monitoring"
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = "0.74.0"

  values = [
    file("${path.module}/values/otel-collector-values.yaml")
  ]
  depends_on = [
    var.alb_controller_dependency,
    kubernetes_namespace.monitoring
  ]
}

# Specifies the required Terraform providers:
terraform {
    required_providers {
    helm = {
    source = "hashicorp/helm"
    version = ">= 2.10"
    }
    kubernetes = {
    source = "hashicorp/kubernetes"
    version = ">= 2.29"
    }
  }
}

# Creates a Kubernetes namespace (e.g., observability) for all observability components.
resource "kubernetes_namespace" "obs" {
    metadata { name = var.namespace }
}

# gp3 storage class configuration
resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  storage_provisioner = "ebs.csi.aws.com"
  parameters = {
    type = "gp3"
  }
  reclaim_policy          = "Delete"
  volume_binding_mode     = "WaitForFirstConsumer"
  allow_volume_expansion  = true
}

# Installs the kube-prometheus-stack Helm chart in the specified namespace.
resource "helm_release" "kps" {
    name = "kube-prometheus-stack"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart = "kube-prometheus-stack"
    namespace = var.namespace
    version = var.kps_chart_version
    create_namespace = false
    values = [file("${path.module}/values/kube-prometheus-stack.yaml")]
    depends_on = [kubernetes_storage_class.gp3]
    }

# Installs the Fluent Bit Helm chart in the observability namespace.
# Fluent Bit (to CloudWatch Logs via IRSA)
resource "helm_release" "fluent_bit" {
    name = "fluent-bit"
    repository = "https://fluent.github.io/helm-charts"
    chart = "fluent-bit"
    namespace = var.namespace
    version = var.fb_chart_version
    #values = [file("${path.module}/values/fluent-bit.yaml")]

    values = [
      templatefile ("${path.module}/values/fluent-bit.yaml.tpl", {
      CLUSTER_NAME = var .cluster_name
      AWS_REGION    = var.region
      FLUENTBIT_ROLE_ARN  = var.fluentbit_role_arn
    })
  ]

    depends_on = [kubernetes_namespace.obs]
}

# Installs the OpenTelemetry Collector Helm chart in the observability namespace.
resource "helm_release" "otel_collector" {
    name = "otel-collector"
    repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
    chart = "opentelemetry-collector"
    namespace = var.namespace
    version = var.otel_chart_version
    values = [file("${path.module}/values/opentelemetry-collector.yaml")]
    depends_on = [kubernetes_namespace.obs]
}

# Conclusion :
# Terraform providers ensure you can manage Kubernetes and Helm resources.
# Namespace is created for all observability components.
# Helm repositories are registered so charts can be fetched.
# Helm releases install kube-prometheus-stack, Fluent Bit, and OpenTelemetry Collector with your custom configurations.
# Values files (values/*.yaml) provide detailed configuration for each component.
# Dependencies ensure resources are created in the correct order.

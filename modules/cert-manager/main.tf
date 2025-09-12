resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.13.2" # Use latest stable

  set =[
    {
    name  = "installCRDs"
    value = "true"
  }
  ]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.9"
  namespace        = "argocd"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [file("${path.module}/values.yaml")]
}
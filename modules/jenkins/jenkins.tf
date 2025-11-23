resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.1.5"
  namespace        = "jenkins"
  create_namespace = true

  wait          = false
  timeout       = 900
  force_update  = true
  replace       = true

  values = [file("${path.module}/values.yaml")]
}
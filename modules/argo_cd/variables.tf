variable "argo_version" {
  description = "Версія Argo CD чарту"
  type        = string
  default     = "7.3.9"
}

variable "argo_namespace" {
  description = "Namespace для Argo CD"
  type        = string
  default     = "argocd"
}
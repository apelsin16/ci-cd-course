variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Увімкнути сканування образів при завантаженні"
  type        = bool
  default     = true
}

variable "region" {
  description = "Регіон AWS"
  type        = string
  default     = "us-west-2"
}

variable "account_id" {
  description = "ID акаунту AWS"
  type        = string
}

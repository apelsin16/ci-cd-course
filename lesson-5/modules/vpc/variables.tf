variable "vpc_cidr_block" {
  description = "CIDR блок для VPC"
  type        = string
}

variable "public_subnets" {
  description = "Список CIDR блоків для публічних підмереж (3)"
  type        = list(string)
}

variable "private_subnets" {
  description = "Список CIDR блоків для приватних підмереж (3)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Список зон доступності AWS (3)"
  type        = list(string)
}

variable "vpc_name" {
  description = "Назва для VPC і ресурсів"
  type        = string
}

variable "region" {
  description = "Регіон AWS"
  type        = string
  default     = "us-west-2"
}

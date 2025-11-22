variable "bucket_name" {
  description = "Унікальна назва S3 бакета для state файлів"
  type        = string
}

variable "table_name" {
  description = "Назва DynamoDB таблиці для state-locking"
  type        = string
  default     = "terraform-locks"
}

variable "region" {
  description = "eu-centeral-1"
  type        = string
  default     = "us-west-2"
}

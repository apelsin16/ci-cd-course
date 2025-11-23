variable "name_prefix" {
  description = "Префікс для всіх ресурсів (наприклад, prod-django)"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC, де буде розміщена БД"
  type        = string
}

variable "private_subnet_ids" {
  description = "Список ID приватних підмереж (мінімум 2 для Multi-AZ/Aurora)"
  type        = list(string)
}

variable "use_aurora" {
  description = "true = Aurora PostgreSQL Cluster, false = звичайна RDS instance"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Тип двигуна: postgres або mysql"
  type        = string
  default     = "postgres"
  validation {
    condition     = contains(["postgres", "mysql"], var.engine)
    error_message = "Дозволені значення: postgres, mysql"
  }
}

variable "engine_version" {
  description = "Версія двигуна (наприклад, 15.5 для PostgreSQL)"
  type        = string
  default     = "17.5"
}

variable "instance_class" {
  description = "Клас інстансу (наприклад, db.t3.medium)"
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Розмір диска в GB (для звичайної RDS)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Ім'я бази даних"
  type        = string
  default     = "mydb"
}

variable "master_username" {
  description = "Ім'я головного користувача"
  type        = string
  default     = "dbmaster"
}

variable "multi_az" {
  description = "Multi-AZ розгортання"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR блоки, з яких дозволений доступ до БД"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "backup_retention_period" {
  description = "Кількість днів зберігання бекапів"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Пропускати фінальний снапшот при destroy"
  type        = bool
  default     = true
}
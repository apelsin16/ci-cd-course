/*
output "s3_bucket_url" {
  description = "URL S3 бакета для state файлів"
  value       = "s3://${module.s3_backend.s3_bucket_id}/"
}

output "dynamodb_lock_table" {
  description = "Назва DynamoDB таблиці для state-locking"
  value       = module.s3_backend.dynamodb_table_name
}
*/

output "vpc_id" {
  description = "ID створеного VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = module.vpc.private_subnet_ids
}

output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = module.ecr.repository_url
}

# outputs.tf — для домашки з RDS
output "db_endpoint" {
  description = "Endpoint бази даних"
  value       = module.rds.db_endpoint
}

output "master_password" {
  description = "Пароль master-користувача"
  value       = module.rds.master_password
  sensitive   = true
}

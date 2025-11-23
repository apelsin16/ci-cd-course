
output "db_endpoint" {
  description = "Endpoint для підключення до БД (cluster endpoint для Aurora)"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].endpoint, null)
  ) : try(aws_db_instance.main[0].endpoint, null)
}

output "db_reader_endpoint" {
  description = "Reader endpoint (тільки для Aurora)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].reader_endpoint, null) : null
}

output "db_arn" {
  description = "ARN бази даних"
  value = var.use_aurora ? (
    try(aws_rds_cluster.aurora[0].arn, null)
  ) : try(aws_db_instance.main[0].arn, null)
}

output "master_password" {
  description = "Згенерований пароль master-користувача"
  value       = random_password.master_password.result
  sensitive   = true
}

output "security_group_id" {
  description = "ID створеної Security Group"
  value       = aws_security_group.rds.id
}
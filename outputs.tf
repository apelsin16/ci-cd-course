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
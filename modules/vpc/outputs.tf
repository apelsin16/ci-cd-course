output "vpc_id" {
  description = "ID створеного VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Список ID публічних підмереж"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Список ID приватних підмереж"
  value       = aws_subnet.private[*].id
}

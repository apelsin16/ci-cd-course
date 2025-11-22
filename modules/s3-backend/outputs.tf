output "s3_bucket_id" {
  description = "ID S3 бакета для state файлів"
  value       = aws_s3_bucket.state_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN S3 бакета для state файлів"
  value       = aws_s3_bucket.state_bucket.arn
}

output "dynamodb_table_name" {
  description = "Назва DynamoDB таблиці для блокування"
  value       = aws_dynamodb_table.lock_table.name
}

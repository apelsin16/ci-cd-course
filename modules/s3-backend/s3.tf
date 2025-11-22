resource "aws_s3_bucket" "state_bucket" {
  bucket = var.bucket_name
  # Використання стандартних налаштувань для бакетів
}

# Обов'язково вмикаємо версіювання
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Встановлюємо політику публічного доступу на Blocked
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Додамо теги
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.state_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
/*
resource "aws_s3_bucket_acl" "state_bucket_acl" {
  bucket = aws_s3_bucket.state_bucket.id
  acl    = "private"
}
*/

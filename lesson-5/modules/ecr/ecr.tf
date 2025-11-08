resource "aws_ecr_repository" "main" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name = var.ecr_name
  }
}

# Налаштування політики доступу: дозволяємо всім користувачам в акаунті пушити/тягнути
resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid       = "FullAccessForAccount"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:DeleteRepositoryPolicy"
        ]
      },
    ]
  })
}

# Бекенд налаштовується до першого 'terraform init'
# Він використовує ресурси, створені модулем s3_backend
terraform {
  backend "s3" {
    bucket         = "my-unique-bucket-name-lesson5" # <--- ПОВИННО ЗБІГАТИСЯ З main.tf
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

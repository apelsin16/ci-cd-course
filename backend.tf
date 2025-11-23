terraform {
  backend "s3" {
    bucket         = "my-unique-bucket-name-lesson-8-9"
    key            = "lesson-8-9/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Конфігурація провайдера AWS
provider "aws" {
  region = "us-west-2" # Використовуємо регіон з умови
}

data "aws_caller_identity" "current" {}

# Підключаємо модуль S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-unique-bucket-name-lesson5" # <--- ОБОВ'ЯЗКОВО ЗАМІНИТИ
  table_name  = "terraform-locks"
  region      = "us-west-2"
}

# Підключаємо модуль VPC
module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-5-vpc"
  region             = "us-west-2"
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
  account_id   = data.aws_caller_identity.current.account_id
}

# Підключаємо модуль EKS
module "eks" {
  source                 = "./modules/eks"
  cluster_name           = "django-k8s-cluster"
  vpc_id                 = module.vpc.vpc_id # Припускаємо, що vpc.tf виводить vpc_id
  public_subnet_ids      = module.vpc.public_subnet_ids # Припускаємо, що vpc.tf виводить public_subnet_ids
  private_subnet_ids     = module.vpc.private_subnet_ids # Припускаємо, що vpc.tf виводить private_subnet_ids
  instance_type          = "t3.medium"
  desired_size           = 2
  max_size               = 4
  min_size               = 1
  region                 = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

# Конфігурація провайдера AWS
provider "aws" {
  region = "us-west-2" # Використовуємо регіон з умови
}

data "aws_caller_identity" "current" {}

# Підключаємо модуль S3 та DynamoDB
/*
module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "my-unique-bucket-name-lesson-8-9" # <--- ОБОВ'ЯЗКОВО ЗАМІНИТИ
  table_name  = "terraform-locks"
  region      = "us-west-2"
}
*/

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
  ecr_name     = "lesson-8-ecr"
  scan_on_push = true
  account_id   = data.aws_caller_identity.current.account_id
}

# Підключаємо модуль EKS
module "eks" {
  source             = "./modules/eks"
  cluster_name       = "django-k8s-cluster"
  vpc_id             = module.vpc.vpc_id             # Припускаємо, що vpc.tf виводить vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids  # Припускаємо, що vpc.tf виводить public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids # Припускаємо, що vpc.tf виводить private_subnet_ids
  instance_type      = "t3.xlarge"
  desired_size       = 2
  max_size           = 4
  min_size           = 1
  region             = "us-west-2"
}

# --- Налаштування провайдерів K8s та Helm ---
# Вони використовують виводи (outputs) модуля EKS для автентифікації

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# --- Підключення модулів Jenkins та Argo CD ---

module "jenkins" {
  source     = "./modules/jenkins"
  depends_on = [module.eks] # Jenkins ставиться тільки після готовності EKS
}

module "argo_cd" {
  source     = "./modules/argo_cd"
  depends_on = [module.eks] # ArgoCD ставиться тільки після готовності EKS
}
/*
resource "kubernetes_storage_class" "gp3_default" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    type      = "gp3"
    encrypted = "true"
  }
}
*/
# Тільки Aurora (найпростіше і найдешевше)
module "rds" {
  source = "./modules/rds"

  name_prefix        = "lesson"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  use_aurora         = true
  allowed_cidr_blocks = ["10.0.0.0/16"]
}

# Prometheus + Grafana
module "monitoring" {
  source = "./modules/monitoring"
  depends_on = [module.eks]
}
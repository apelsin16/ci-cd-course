provider "aws" { region = "us-west-2" }

module "vpc" {
  source = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b"]
  vpc_name           = "rds-test"
}

# Тільки Aurora (найпростіше і найдешевше)
module "rds" {
  source = "./modules/rds"

  name_prefix        = "lesson"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  use_aurora         = true
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
# Універсальний модуль RDS + Aurora

## Використання

```hcl
module "rds" {
  source = "./modules/rds"

  name_prefix        = "myapp-prod"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  use_aurora         = true  # false = звичайна RDS
  engine             = "postgres"
  engine_version     = "15.5"
  instance_class     = "db.t3.medium"
  db_name            = "myapp"
}
resource "aws_db_subnet_group" "main" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "${var.name_prefix}-subnet-group" }
}

resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  vpc_id      = var.vpc_id
  description = "Security group for RDS/Aurora"

  ingress {
    description = "PostgreSQL/MySQL from VPC"
    from_port   = var.engine == "postgres" ? 5432 : 3306
    to_port     = var.engine == "postgres" ? 5432 : 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name_prefix}-rds-sg" }
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.name_prefix}-params"
  family = var.use_aurora ? "aurora-postgresql17" : "${var.engine}${split(".", var.engine_version)[0]}"

  parameter {
    name         = "max_connections"
    value        = "300"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "work_mem"
    value        = "16384"
    apply_method = "immediate"
  }

  tags = { Name = "${var.name_prefix}-params" }
}
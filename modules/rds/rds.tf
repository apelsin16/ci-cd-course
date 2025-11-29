resource "aws_db_instance" "main" {
  count = var.use_aurora ? 0 : 1

  identifier              = "${var.name_prefix}-db"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.master_username
  password                = random_password.master_password.result
  parameter_group_name    = aws_db_parameter_group.main.name
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]

  multi_az                = var.multi_az
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name_prefix}-final-snapshot"

  tags = {
    Name = "${var.name_prefix}-rds"
  }
}

resource "random_password" "master_password" {
  length  = 20
  special = false
}
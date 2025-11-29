resource "aws_rds_cluster" "aurora" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = "${var.name_prefix}-aurora-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "17.5"  # ← правильна версія
  database_name           = var.db_name
  master_username         = var.master_username
  master_password         = random_password.master_password.result

  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  storage_encrypted       = true

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = "${var.name_prefix}-final"

  tags = { Name = "${var.name_prefix}-aurora-cluster" }
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  count = var.use_aurora ? 1 : 0

  identifier         = "${var.name_prefix}-writer"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.aurora[0].engine
  publicly_accessible = false
}
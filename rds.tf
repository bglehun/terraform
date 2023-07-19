resource "aws_rds_cluster_parameter_group" "cluster_parameter_group" {
  name        = "${var.app_name}-cluster-pg"
  family      = "aurora-mysql8.0"
  description = "RDS cluster parameter group for ${var.app_name}"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "${var.app_name}-db-pg"
  family      = "aurora-mysql8.0"
  description = "RDS db parameter group for ${var.app_name}"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.app_name}-vpc-subnet-group"
  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "${var.app_name}-vpc-subnet-group"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier              = var.app_name
  engine                          = "aurora-mysql"
  engine_mode                     = "provisioned"
  engine_version                  = "8.0.mysql_aurora.3.03.1"
  database_name                   = "chat"
  master_username                 = var.mysql_user
  master_password                 = var.mysql_password // longer than 8 characters..
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.cluster_parameter_group.name
  deletion_protection             = false
  network_type                    = "IPV4"
  storage_encrypted               = true
  port                            = 3306
  db_subnet_group_name            = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot             = true
  final_snapshot_identifier       = "${var.app_name}-snapshot"
  apply_immediately               = true
  availability_zones              = slice(data.aws_availability_zones.available_zones.names, 0, var.subnet_count)
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]

  lifecycle {
    ignore_changes = [availability_zones, cluster_identifier]
  }
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  count                                 = 2
  identifier                            = "${aws_rds_cluster.rds_cluster.id}-instance-${count.index}"
  cluster_identifier                    = aws_rds_cluster.rds_cluster.id
  engine                                = aws_rds_cluster.rds_cluster.engine
  engine_version                        = aws_rds_cluster.rds_cluster.engine_version
  instance_class                        = "db.t4g.medium"
  db_parameter_group_name               = aws_db_parameter_group.db_parameter_group.name
  auto_minor_version_upgrade            = false
  publicly_accessible                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
}

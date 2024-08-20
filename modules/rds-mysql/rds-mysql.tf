
locals {
  calc_max_allocated_storage = var.allocated_storage + (var.allocated_storage * 100 / 10)
  name                       = lower("${var.name}-${var.environment}-db")
  tags                       = var.tags
}

resource "random_pet" "rds_final_snapshot" {
  prefix    = "snapshot"
  separator = "-"
}

resource "aws_db_instance" "rdsmysql" {
  vpc_security_group_ids = var.security_groups
  
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = local.calc_max_allocated_storage
  db_name                     = "defaultdb"
  engine                      = "mysql"
  engine_version              = "8.0"
  instance_class              = var.instance_class
  manage_master_user_password = true
  username                    = "dbadmin"
  storage_encrypted           = true
  multi_az                    = var.ha
  identifier                  = local.name
  deletion_protection         = var.deletion_protection
  db_subnet_group_name        = var.subnet_group_name
  skip_final_snapshot         = var.environment == "prod" ? false : true
  final_snapshot_identifier   = var.environment == "prod" ? "${lower(local.name)}-${lower(random_pet.rds_final_snapshot.id)}" : null
  parameter_group_name        = aws_db_parameter_group.pg.name
  
}

resource "aws_db_parameter_group" "pg" {
  name   = "${local.name}-pg"
  family = "mysql8.0"

  dynamic "parameter" {
    for_each = var.db_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
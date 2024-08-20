locals {
  db_sg_name               = "${var.name}-db-sg"
  create_db_security_group = var.config.create_db_security_group == true ? 1 : 0
}

resource "aws_security_group" "db_sg" {
  count       = local.create_db_security_group
  name        = local.db_sg_name
  vpc_id      = var.vpc_id
  description = "Database Security Group"
  tags = merge(local.tags, {
    Name = local.db_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "database_security_group_ingress" {
  count                        = local.create_db_security_group
  depends_on                   = [aws_security_group.db_sg]
  security_group_id            = aws_security_group.db_sg[0].id
  referenced_security_group_id = aws_security_group.app_sg[0].id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
  description                  = "Allow traffic from Application to Database port"
}


resource "aws_vpc_security_group_egress_rule" "allow_egress_to_app_sg" {
  count                        = local.create_db_security_group
  depends_on                   = [aws_security_group.db_sg, aws_security_group.app_sg]
  security_group_id            = aws_security_group.db_sg[0].id
  referenced_security_group_id = aws_security_group.app_sg[0].id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
  description                  = "Allow Database Port to Application"
}

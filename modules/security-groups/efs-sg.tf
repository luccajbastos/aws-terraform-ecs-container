locals {
  efs_sg_name               = "${var.name}-efs-sg"
  create_efs_security_group = var.config.create_efs_security_group == true ? 1 : 0
}

resource "aws_security_group" "efs_sg" {
  count       = local.create_efs_security_group
  name        = local.efs_sg_name
  vpc_id      = var.vpc_id
  description = "EFS Security Group"
  tags = merge(local.tags, {
    Name = local.efs_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_efs_ingress" {
  count                        = local.create_efs_security_group
  depends_on                   = [aws_security_group.alb_sg, aws_security_group.efs_sg]
  security_group_id            = aws_security_group.efs_sg[0].id
  referenced_security_group_id = aws_security_group.app_sg[0].id
  from_port                    = 2049
  ip_protocol                  = "tcp"
  to_port                      = 2049
  description                  = "Allow Application Ingress"
}

resource "aws_vpc_security_group_egress_rule" "allow_efs_egress" {
  count                        = local.create_efs_security_group
  depends_on                   = [aws_security_group.efs_sg]
  security_group_id            = aws_security_group.efs_sg[0].id
  referenced_security_group_id = aws_security_group.app_sg[0].id
  ip_protocol                  = "tcp"
  from_port                    = 2049
  to_port                      = 2049
  description                  = "Allow EFS port to App SG"
}

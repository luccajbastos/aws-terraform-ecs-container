locals {
  app_sg_name               = "${var.name}-app-sg"
  create_app_security_group = var.config.create_app_security_group == true ? 1 : 0
}

resource "aws_security_group" "app_sg" {
  count       = local.create_app_security_group
  name        = local.app_sg_name
  vpc_id      = var.vpc_id
  description = "Wordpress Security Group"
  tags = merge(local.tags, {
    Name = local.app_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_ingress" {
  count                        = local.create_app_security_group
  depends_on                   = [aws_security_group.alb_sg, aws_security_group.app_sg]
  security_group_id            = aws_security_group.app_sg[0].id
  referenced_security_group_id = aws_security_group.alb_sg[0].id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
  description                  = "Allow ALB Ingress"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_app" {
  count             = local.create_app_security_group
  depends_on        = [aws_security_group.app_sg]
  security_group_id = aws_security_group.app_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow All Traffic to Internet"
}

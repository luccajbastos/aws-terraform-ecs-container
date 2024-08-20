locals {
  alb_sg_name               = "${var.name}-alb-sg"
  create_alb_security_group = var.config.create_alb_security_group == true ? 1 : 0
}

resource "aws_security_group" "alb_sg" {
  count       = local.create_alb_security_group
  name        = local.alb_sg_name
  vpc_id      = var.vpc_id
  description = "Application Load Balancer Security Group"
  tags = merge(local.tags, {
    Name = local.alb_sg_name
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_443_ipv4" {
  count             = local.create_alb_security_group
  depends_on        = [aws_security_group.alb_sg]
  security_group_id = aws_security_group.alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "Allow all-traffic from Internet to TLS port"
}

resource "aws_vpc_security_group_ingress_rule" "allow_80_ipv4" {
  count             = local.create_alb_security_group
  depends_on        = [aws_security_group.alb_sg]
  security_group_id = aws_security_group.alb_sg[0].id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "Allow all-traffic from Internet to HTTP port"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  count                        = local.create_alb_security_group
  depends_on                   = [aws_security_group.alb_sg, aws_security_group.app_sg]
  security_group_id            = aws_security_group.alb_sg[0].id
  referenced_security_group_id = aws_security_group.app_sg[0].id
  ip_protocol                  = "-1"
  description                  = "Allow All Traffic to Application"
}

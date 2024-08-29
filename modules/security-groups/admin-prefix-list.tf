locals {
  pl_name = "${var.name}-admins-pl"
}

resource "aws_ec2_managed_prefix_list" "admins" {
  name           = local.pl_name
  address_family = "IPv4"
  max_entries    = 5


  dynamic "entry" {
    for_each = var.admin_ips

    content {
      cidr        = entry.value.ip
      description = entry.value.description
    }

  }

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_admins_inbound" {
  depends_on        = [aws_ec2_managed_prefix_list.admins, aws_security_group.app_sg]
  security_group_id = aws_security_group.app_sg[0].id
  prefix_list_id    = aws_ec2_managed_prefix_list.admins.id

  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
  description = "Allow SSH from Admins Prefix List"
}

resource "aws_vpc_security_group_egress_rule" "allow_admins_outbound" {
  depends_on        = [aws_ec2_managed_prefix_list.admins, aws_security_group.app_sg]
  security_group_id = aws_security_group.app_sg[0].id
  prefix_list_id    = aws_ec2_managed_prefix_list.admins.id
  ip_protocol       = "-1"
  description       = "Allow All Traffic to Admins Prefix List"
}
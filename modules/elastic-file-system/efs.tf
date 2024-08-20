locals {
  name = lower("${var.name}-efs")
}

resource "aws_efs_file_system" "file_system" {
  creation_token   = local.name
  performance_mode = var.performance_mode

  tags = var.tags
}

resource "aws_efs_mount_target" "mount" {
  count = length(var.subnets)

  file_system_id = aws_efs_file_system.file_system.id
  subnet_id      = var.subnets[count.index]
  security_groups = var.security_groups_ids
}
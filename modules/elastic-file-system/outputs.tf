output "efs_mount_points" {
  value = aws_efs_mount_target.mount.*.mount_target_dns_name
}
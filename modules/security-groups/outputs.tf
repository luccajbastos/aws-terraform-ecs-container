output "alb_security_group_id" {
  value = aws_security_group.alb_sg[*].id
}

output "application_security_group_id" {
  value = aws_security_group.app_sg[*].id
}

output "efs_security_group_id" {
  value = aws_security_group.efs_sg[*].id
}

output "db_security_group_id" {
  value = aws_security_group.db_sg[*].id
}
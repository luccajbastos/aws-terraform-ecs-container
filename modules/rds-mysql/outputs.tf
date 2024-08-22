output "db_host" {
  value = aws_db_instance.rdsmysql.address
}

output "db_name" {
  value = aws_db_instance.rdsmysql.db_name
}

output "db_username" {
  value = aws_db_instance.rdsmysql.username
}

output "db_password" {
  value = aws_db_instance.rdsmysql.password
}

output "credentials" {
  value = data.aws_secretsmanager_secret_version.current.secret_string
}
output "db_endpoint" {
  value = aws_db_instance.my_instance_rds.address
}

output "db_port" {
  value = aws_db_instance.my_instance_rds.port
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.my_db_secret.arn
}

output "db_sg_id" {
  value = aws_security_group.my_rds_sg.id
}
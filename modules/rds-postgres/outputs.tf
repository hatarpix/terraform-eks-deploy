output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}

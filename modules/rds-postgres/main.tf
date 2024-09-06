
resource "aws_db_instance" "postgres" {
  engine                  = "postgres"
  engine_version          = var.postgres_version
  instance_class          = var.postgres_instance_class
  allocated_storage       = 20
  storage_type            = "gp3"
  identifier              = "pg-${var.project_name}"
  username                = "postgres"
  password                = var.postgres_master_password
  multi_az                = false
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  backup_retention_period = 2
  storage_encrypted       = true
  maintenance_window      = "sat:03:00-sat:04:00"
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${var.project_name}"
  subnet_ids = concat(var.public_subnets, var.private_subnets)
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg-${var.project_name}"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg-${var.project_name}"
  }
}
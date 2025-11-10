resource "aws_db_subnet_group" "devops_rds_subnet_group" {
  name = "devops-rds-subnets"
  subnet_ids = [
    aws_subnet.devops_private_1.id,
    aws_subnet.devops_private_2.id
  ]
  tags = {
    Name = "devops-rds-subnets"
  }
}

resource "random_password" "db_password" {
  length           = 20
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "devops-rds-db-credentials"

  tags = {
    Name = "devops-rds-db-credentials"
  }

}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    db_name  = var.db_name
  })

}

resource "aws_db_instance" "devops_rds" {
  identifier             = "devops-rds-instance"
  engine                 = "postgres"
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.devops_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.devops_rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "devops-rds-instance"
  }
}
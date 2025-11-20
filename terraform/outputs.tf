output "ec2_public_ips" {
  value = aws_instance.devops_instance[0].public_ip
}

output "alb_dns_name" {
  value = aws_lb.devops_alb.dns_name
}

output "db_host" {
  value = aws_db_instance.devops_rds.address
}

output "db_name" {
  value = aws_db_instance.devops_rds.db_name
}

output "tf_state_bucket_name" {
  value = aws_s3_bucket.tf_state_bucket.bucket
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  value = aws_secretsmanager_secret.db_credentials.name
}
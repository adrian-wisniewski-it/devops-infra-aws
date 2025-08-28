output "ec2_public_ips" {
  value = aws_instance.devops_instance[*].public_ip
}

output "alb_dns_name" {
  value = aws_lb.devops_alb.dns_name
}
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "devops-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU utilization is too high"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.devops_rds.identifier
  }

  tags = {
    Name = "devops-rds-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "devops-rds-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648
  alarm_description   = "RDS free storage space is less than 2GB"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.devops_rds.identifier
  }

  tags = {
    Name = "devops-rds-storage-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "devops-ec2-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU utilization is too high"

  dimensions = {
    InstanceId = aws_instance.devops_instance[0].id
  }

  tags = {
    Name = "devops-ec2-cpu-alarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "devops-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"

  dimensions = {
    LoadBalancer = aws_lb.devops_alb.arn_suffix
    TargetGroup  = aws_lb_target_group.devops_lb_tg.arn_suffix
  }

  tags = {
    Name = "devops-alb-unhealthy-alarm"
  }
}
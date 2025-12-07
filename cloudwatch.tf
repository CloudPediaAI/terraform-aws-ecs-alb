
# CloudWatch Alarms for ECS Service Monitoring and Rollback
resource "aws_cloudwatch_metric_alarm" "containerized_app_ecs_service_cpu_high" {
  alarm_name          = local.ecs_cloudwatch_alarm_cpu_high
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = []

  dimensions = {
    ServiceName = aws_ecs_service.containerized_app.name
    ClusterName = aws_ecs_cluster.containerized_app.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "containerized_app_alb_target_response_time" {
  alarm_name          = local.ecs_cloudwatch_alarm_alb_resp_time_high
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1" # 1 second threshold
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.containerized_app.arn_suffix
    TargetGroup  = aws_lb_target_group.containerized_app.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "containerized_app_alb_unhealthy_targets" {
  alarm_name          = local.ecs_cloudwatch_alarm_alb_unhealthy_targets
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "This metric monitors unhealthy targets in ALB"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.containerized_app.arn_suffix
    TargetGroup  = aws_lb_target_group.containerized_app.arn_suffix
  }

  tags = var.tags
}
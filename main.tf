terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.36.0"
      configuration_aliases = [aws.us-east-1, aws]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
}

locals {
  # use default VPC if vpc_id is not provided by user
  vpc_id   = coalesce(var.vpc_id, data.aws_vpc.default.id)
  need_ssl = (var.domain_name != null && var.hosted_zone_id != null)

  ecs_app_name       = var.app_name_prefix
  ecs_app_short_name = var.app_name_prefix # this is to restrict ALB name less than 32 chars
  ecr_repo_name      = "${local.ecs_app_name}-ecr-repo"

  ecs_name_prefix      = "${local.ecs_app_name}-ecs"
  ecs_task_family_name = "${local.ecs_name_prefix}-tasks"
  ecs_cluster_name     = "${local.ecs_name_prefix}-cluster"
  ecs_service_name     = "${local.ecs_name_prefix}-service"
  ecs_container_name   = "${local.ecs_name_prefix}-container-1"

  ecs_log_group_name             = "/ecs/${local.ecs_name_prefix}-logs"
  ecs_role_task_execution        = "${local.ecs_name_prefix}-task-exec-role"
  ecs_task_role_name             = "${local.ecs_name_prefix}-task-role"
  ecs_task_policy_name           = "${local.ecs_name_prefix}-task-policy"
  ecs_task_execution_policy_name = "${local.ecs_name_prefix}-task-execution-policy"
  ecs_security_group_name        = "${local.ecs_name_prefix}-tasks-sg"

  ecs_alb_name                               = "${local.ecs_app_short_name}-alb"
  ecs_alb_security_group_name                = "${local.ecs_alb_name}-sg"
  ecs_alb_target_group_name                  = "${local.ecs_alb_name}-tg"
  ecs_cloudwatch_alarm_cpu_high              = "${local.ecs_alb_name}-cpu-high"
  ecs_cloudwatch_alarm_alb_resp_time_high    = "${local.ecs_alb_name}-response-time-high"
  ecs_cloudwatch_alarm_alb_unhealthy_targets = "${local.ecs_alb_name}-unhealthy-targets"

  health_check_path = "http://localhost:${var.app_port}${var.health_check_endpoint}"
  app_alb_port      = local.need_ssl ? 443 : 80
  alb_http_endpoint = "http://${aws_lb.containerized_app.dns_name}:${local.app_alb_port}"
  alb_endpoint      = local.need_ssl ? "https://${var.domain_name}" : local.alb_http_endpoint
}

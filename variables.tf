variable "app_name_prefix" {
  description = "Prefix name for your application name.  This module will create all AWS resources with this prefix."
  type        = string
  default     = "containerized-app"
}

variable "aws_region" {
  description = "AWS Region to create resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "VPC to create Security Groups and ALB Target Group"
  type        = string
  default     = null
}

variable "app_port" {
  description = "HTTP port for the application"
  type        = number
  default     = 80
}

variable "domain_name" {
  description = "Custom domain name for the application load balancer.  This is required if you want to use HTTPS with a custom domain."
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "Hosted zone ID for the Route53 DNS.  This is required if domain_name is specified."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "Key/Value pairs for the tags"
  default = {
    created_by = "Terraform Module cloudpediaai/ecs-alb/aws"
  }
}

variable "need_logging" {
  description = "API Logging will be ENABLED if true"
  type        = bool
  default     = false
}

variable "container_env_vars" {
  description = "Environment variables to configure in container"
  type        = list(map(string))
  default     = []
}

variable "ecr_image_retention_count" {
  description = "Number of images to retain in ECR repository lifecycle policy"
  type        = number
  default     = 10
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs for ECS tasks"
  type        = number
  default     = 7
}

variable "ecs_desired_count" {
  description = "Number of tasks to run in the ECS service"
  type        = number
  default     = 1
}

variable "ecs_deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can be running during a deployment"
  type        = number
  default     = 200
}

variable "ecs_deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks that must remain running during a deployment"
  type        = number
  default     = 50
}

variable "ecs_force_new_deployment" {
  description = "Whether to force a new deployment when the service is updated"
  type        = bool
  default     = false
}

variable "ecs_wait_for_steady_state" {
  description = "Whether to wait for the ECS service to reach a steady state during deployment"
  type        = bool
  default     = false
}

variable "need_alerts" {
  description = "Secrets to configure in container"
  type        = list(map(string))
  default     = []
}

variable "health_check_endpoint" {
  description = "Endpoint for health check"
  type        = string
  default     = "/health"
}

variable "alb_allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_cpu" {
  type        = number
  description = "The number of CPU units to allocate for the ECS task"
  default     = 512
}

variable "ecs_memory" {
  type        = number
  description = "The amount of memory (in MiB) to allocate for the ECS task"
  default     = 1024
}

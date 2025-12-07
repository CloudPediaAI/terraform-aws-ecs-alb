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
}

output "vpc_id" {
  value       = local.vpc_id
  description = "The VPC where all resources got created"
}

# Output ECR Repository URL
output "ecr_repository_uri" {
  value       = aws_ecr_repository.containerized_app.repository_url
  description = "ECR repository URI"
}

# Output ECS Service Name
output "ecs_service_name" {
  value       = aws_ecs_service.containerized_app.name
  description = "ECS service name"
}

# Output ECS Cluster Name
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.containerized_app.name
  description = "ECS cluster name"
}

output "ecs_task_family_name" {
  value       = local.ecs_task_family_name
  description = "Task definition family name"
}

# Output ECS Container Name
output "ecs_container_name" {
  value       = local.ecs_container_name
  description = "ECS container name"
}

# Output ALB DNS Name for direct access (useful for testing)
output "alb_dns_name" {
  value       = aws_lb.containerized_app.dns_name
  description = "ALB DNS name for direct access"
}

# Output ALB Security Group ID
output "alb_security_group_id" {
  value       = aws_security_group.containerized_app_alb.id
  description = "Security group ID for the Application Load Balancer"
}

# Output ECS Tasks Security Group ID
output "ecs_tasks_security_group_id" {
  value       = aws_security_group.containerized_app_ecs_tasks.id
  description = "Security group ID for the ECS tasks"
}


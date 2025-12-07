output "vpc_id" {
  value = local.vpc_id
  description = "VPC where all resources got created"
}

# Output ECR Repository URL
output "ecr_repository_url" {
  value       = aws_ecr_repository.containerized_app.repository_url
  description = "ECR repository URL for API"
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

# Output ALB DNS Name for direct access (useful for testing)
output "alb_dns_name" {
  value       = aws_lb.containerized_app.dns_name
  description = "ALB DNS name for direct access"
}

# Output ALB Zone ID
output "alb_zone_id" {
  value       = aws_lb.containerized_app.zone_id
  description = "ALB hosted zone ID"
}

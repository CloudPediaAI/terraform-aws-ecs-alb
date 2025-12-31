
# ECS Cluster
resource "aws_ecs_cluster" "containerized_app" {
  name     = local.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "containerized_app" {
  name              = local.ecs_log_group_name
  retention_in_days = var.cloudwatch_log_retention_days

  tags = var.tags
}

# Role that the Amazon ECS container agent and the Docker daemon can assume.
resource "aws_iam_role" "containerized_app_ecs_task_execution" {
 name     = local.ecs_role_task_execution

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "containerized_app_ecs_task_execution" {
  role       = aws_iam_role.containerized_app_ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (for containers to access other AWS services)
resource "aws_iam_role" "containerized_app_ecs_task_role" {
  name     = local.ecs_task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Task role policy for basic container operations
resource "aws_iam_role_policy" "containerized_app_ecs_task_role_policy" {
  name     = local.ecs_task_policy_name
  role     = aws_iam_role.containerized_app_ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.containerized_app.arn}:*"
      }
    ]
  })
}

# Additional policy for ECR access
resource "aws_iam_role_policy" "containerized_app_ecs_task_execution_ecr" {
  name     = local.ecs_task_execution_policy_name
  role     = aws_iam_role.containerized_app_ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      Resource = "*"
    }]
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "containerized_app" {
  family                   = local.ecs_task_family_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.containerized_app_ecs_task_execution.arn
  task_role_arn            = aws_iam_role.containerized_app_ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = local.ecs_container_name
    image     = "${aws_ecr_repository.containerized_app.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = var.app_port
      hostPort      = var.app_port
      protocol      = "tcp"
    }]

    environment = var.container_env_vars

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.containerized_app.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = {
      command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider ${local.health_check_path} || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 5
      startPeriod = 120
    }
  }])

  tags = var.tags
}

# Security Group for ECS Tasks
resource "aws_security_group" "containerized_app_ecs_tasks" {
  name        = local.ecs_security_group_name
  description = "Security group for ECS tasks"
  vpc_id      = local.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = local.ecs_security_group_name
  })
}

# ECS Service
resource "aws_ecs_service" "containerized_app" {
  name            = local.ecs_service_name
  cluster         = aws_ecs_cluster.containerized_app.id
  task_definition = aws_ecs_task_definition.containerized_app.arn
  desired_count   = var.ecs_desired_count
  launch_type     = "FARGATE"

  # Enable service connect for better service discovery (optional)
  enable_execute_command = true

  # Deployment configuration for rolling updates
  deployment_maximum_percent         = var.ecs_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_deployment_minimum_healthy_percent

  # Force new deployment when task definition changes
  force_new_deployment = var.ecs_force_new_deployment

  # Wait for steady state during deployment
  wait_for_steady_state = var.ecs_wait_for_steady_state

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.containerized_app_ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.containerized_app.arn
    container_name   = local.ecs_container_name
    container_port   = var.app_port
  }

  depends_on = [aws_lb_listener.containerized_app_http, aws_iam_role.containerized_app_ecs_task_execution, aws_iam_role.containerized_app_ecs_task_role]

  tags = var.tags
}


# Application Load Balancer for ECS Service
resource "aws_lb" "containerized_app" {
  name               = local.ecs_alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.containerized_app_alb.id]
  subnets            = data.aws_subnets.default.ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = local.ecs_alb_name
  })
}

# Security Group for ALB
resource "aws_security_group" "containerized_app_alb" {
  name        = local.ecs_alb_security_group_name
  description = "Security group for ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTP from CloudFront"
    from_port   = local.app_alb_port
    to_port     = local.app_alb_port
    protocol    = "tcp"
    cidr_blocks = var.alb_allowed_cidr_blocks
  }

  # ingress {
  #   description = "Allow HTTPS from Public"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = local.ecs_alb_security_group_name
  })
}

# Security Group Rule: ALB to ECS Tasks
resource "aws_security_group_rule" "containerized_app_alb_to_ecs" {
  type                     = "ingress"
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.containerized_app_alb.id
  security_group_id        = aws_security_group.containerized_app_ecs_tasks.id
  description              = "Allow traffic from ALB to ECS tasks"
}

# ALB Target Group
resource "aws_lb_target_group" "containerized_app" {
  name        = local.ecs_alb_target_group_name
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200"
    path                = var.health_check_endpoint
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 5
  }

  tags = merge(var.tags, {
    Name = local.ecs_alb_target_group_name
  })
}

# ALB Listener - HTTP
resource "aws_lb_listener" "containerized_app_http" {
  count = local.need_ssl ? 0 : 1

  load_balancer_arn = aws_lb.containerized_app.arn
  port              = local.app_alb_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.containerized_app.arn
  }
}

# ALB Listener - HTTP (redirect to HTTPS)
resource "aws_lb_listener" "containerized_app_http_redirect" {
  count = local.need_ssl ? 1 : 0

  load_balancer_arn = aws_lb.containerized_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ALB Listener - HTTPS
resource "aws_lb_listener" "containerized_app_https" {
  count = local.need_ssl ? 1 : 0

  load_balancer_arn = aws_lb.containerized_app.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.alb_cert[0].certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.containerized_app.arn
  }

  depends_on = [aws_acm_certificate_validation.alb_cert]
}

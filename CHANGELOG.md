# Changelog

All notable changes to this Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-06

### Added
- **Core Infrastructure**
  - ECS Fargate cluster with Container Insights enabled
  - Application Load Balancer (ALB) with configurable port mapping
  - ECR repository with lifecycle policy (keep last 10 images)
  - VPC integration with default VPC support or custom VPC specification

- **Security & Networking**
  - Security groups for ECS tasks and ALB with proper ingress/egress rules
  - IAM roles for ECS task execution and task operations
  - ECR access permissions for container image pulling
  - Public subnet deployment with configurable security

- **SSL/TLS & Domain Management**
  - ACM certificate provisioning with DNS validation
  - Route53 integration for custom domain setup
  - HTTPS listener with SSL termination at load balancer
  - HTTP to HTTPS redirect when SSL is enabled
  - Support for both A and AAAA records

- **Container Configuration**
  - Configurable container environment variables
  - Health check endpoint configuration (`/`)
  - CloudWatch Logs integration with 7-day retention
  - Fargate deployment with 512 CPU / 1024 MB memory allocation

- **Monitoring & Observability**
  - CloudWatch alarms for CPU utilization monitoring (>80% threshold)
  - ALB target response time monitoring (>1 second threshold)
  - Unhealthy target count monitoring
  - ECS service insights and logging

- **Scalability & Deployment**
  - Environment-aware service scaling (dev: 1 replica, others: 2 replicas)
  - Rolling deployment strategy with 50% minimum healthy instances
  - Maximum 200% deployment capacity during updates
  - Target group deregistration delay of 30 seconds

- **Configuration Options**
  - Customizable application name prefix
  - Configurable AWS region (default: us-east-1)
  - Optional VPC ID specification (defaults to default VPC)
  - Configurable application port (default: 80)
  - Optional domain name and hosted zone integration
  - Flexible tagging support
  - Optional logging configuration

### Infrastructure Components
- **ECS Resources**: Cluster, Service, Task Definition, Security Groups
- **Load Balancer**: ALB, Target Groups, Listeners (HTTP/HTTPS)
- **Container Registry**: ECR repository with scanning enabled
- **DNS & Certificates**: Route53 records, ACM certificates
- **Monitoring**: CloudWatch Log Groups, Metric Alarms
- **Security**: IAM roles and policies for service operations

### Outputs
- VPC ID of deployed resources
- ECR repository URL for container image management
- ECS service and cluster names
- ALB DNS name and hosted zone ID

### Technical Specifications
- **Terraform Provider**: AWS ~> 5.36.0 with multi-region support
- **Container Platform**: AWS Fargate with awsvpc networking mode
- **Load Balancer**: Application Load Balancer with internet-facing configuration
- **Image Management**: ECR with vulnerability scanning and lifecycle policies
- **Deployment**: Blue/green style rolling deployments

## [1.1.0] - 2025-12-07

- Included new Output variable ecs_container_name

## [1.1.1] - 2025-12-07
- Added Output variables for security group ids 
- Introduced allowed CIDR blocks variable

## [1.1.2] - 2025-12-07
- added ALB endpoint output
- refactor ALB port variable usage

## [1.1.5] - 2025-12-29

### Fixed
- Resolved intermittent health check failures during deployment
- Fixed ALB target deregistration timeout issues
- Corrected IAM policy permissions for enhanced CloudWatch access
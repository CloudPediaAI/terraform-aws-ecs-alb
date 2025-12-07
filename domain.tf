# SSL Certificate for ALB (Region)
resource "aws_acm_certificate" "alb_cert" {
  count = local.need_ssl ? 1 : 0
  
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# Certificate validation for ALB
resource "aws_acm_certificate_validation" "alb_cert" {
  depends_on = [aws_acm_certificate.alb_cert]

  count = local.need_ssl ? 1 : 0

  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.alb_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]
}

locals {
  # Encode then Decode Validation options to avoid conditional for_each
  domain_validations_str = jsonencode((local.need_ssl) ? aws_acm_certificate.alb_cert[0].domain_validation_options : [
    {
      domain_name           = "dummy"
      resource_record_name  = "dummy"
      resource_record_type  = "CNAME"
      resource_record_value = "dummy"
    },
  ])
  domain_validations = jsondecode(local.domain_validations_str)
  # use first item for validations
  domain_validation = local.domain_validations[0]
}


# Route53 records for ALB certificate validation
resource "aws_route53_record" "alb_cert_validation" {
  depends_on = [aws_acm_certificate.alb_cert]

  count = (local.need_ssl) ? 1 : 0

  zone_id         = var.hosted_zone_id
  ttl             = 60
  allow_overwrite = true
  name            = local.domain_validation.resource_record_name
  records         = [local.domain_validation.resource_record_value]
  type            = local.domain_validation.resource_record_type
}

# Route53 A record for vendor website ALB
resource "aws_route53_record" "containerized_app_alb_a" {
  count = local.need_ssl ? 1 : 0

  zone_id  = var.hosted_zone_id
  name     = var.domain_name
  type     = "A"

  alias {
    name                   = aws_lb.containerized_app.dns_name
    zone_id                = aws_lb.containerized_app.zone_id
    evaluate_target_health = true
  }
}

# Route53 AAAA record for vendor website ALB
resource "aws_route53_record" "containerized_app_alb_aaaa" {
  count = local.need_ssl ? 1 : 0

  zone_id  = var.hosted_zone_id
  name     = var.domain_name
  type     = "AAAA"

  alias {
    name                   = aws_lb.containerized_app.dns_name
    zone_id                = aws_lb.containerized_app.zone_id
    evaluate_target_health = true
  }
}


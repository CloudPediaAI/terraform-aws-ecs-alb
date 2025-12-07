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

# Route53 records for ALB certificate validation
resource "aws_route53_record" "alb_cert_validation" {
  for_each = local.need_ssl ? {
    for dvo in aws_acm_certificate.alb_cert[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

# Certificate validation for ALB
resource "aws_acm_certificate_validation" "alb_cert" {
  count = local.need_ssl ? 1 : 0

  certificate_arn         = aws_acm_certificate.alb_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.alb_cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
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


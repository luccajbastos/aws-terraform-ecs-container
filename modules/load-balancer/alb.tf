locals {
  alb_name = "${var.name}-alb"
}

resource "aws_lb" "alb" {
  name               = lower(local.alb_name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_id
  subnets            = var.alb_subnet_ids

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = local.enable_alb_logs ? aws_s3_bucket.alb_logs_bucket[0].id : 0
    enabled = var.enable_alb_logs
  }

  tags = var.tags
}

locals {
  has_custom_acm_certificate = var.alb_custom_certificate_arn != "" ? true : false
  has_custom_ssl_policy      = var.alb_custom_ssl_policy != "" ? true : false
  create_https_listerner     = local.has_custom_acm_certificate ? true : false
}

resource "aws_lb_listener" "https_listener" {
  depends_on = [aws_lb.alb]
  count      = local.create_https_listerner ? 1 : 0

  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = local.has_custom_ssl_policy ? var.alb_custom_ssl_policy : "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.alb_custom_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Nothing here"
      status_code  = "404"
    }
  }

  timeouts {
    create = "2m"
    update = "2m"
  }

}

resource "aws_lb_listener" "http_listener" {
  depends_on = [aws_lb.alb]

  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  timeouts {
    create = "1m"
    update = "1m"
  }
}